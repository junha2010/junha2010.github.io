import { useEffect, useMemo, useState } from 'react';

type GeneratorId = 'cat' | 'worker' | 'building' | 'tower' | 'company' | 'band';

type GeneratorConfig = {
  id: GeneratorId;
  label: string;
  description: string;
  initials: string;
  baseCost: number;
  basePower: number;
  costMultiplier: number;
  maxBonusText: string;
  tiers: Array<{ maxOwned: number; multiplier: number }>;
};

type GeneratorState = {
  owned: number;
  cost: number;
  power: number;
  boost: number;
};

type GameState = {
  money: number;
  perClick: number;
  perSecond: number;
  mainUpgradeCost: number;
  mainUpgradeOwned: number;
  generators: Record<GeneratorId, GeneratorState>;
};

const MAX_GENERATOR_LEVEL = 50;
const MAX_MAIN_UPGRADE_LEVEL = 120;
const MAX_SAFE_COST = Number.MAX_SAFE_INTEGER;
const CASINO_SPIN_COST = 100;
const CASINO_TWO_MATCH_REWARD = 250;
const CASINO_THREE_MATCH_REWARD = 1000;
const CASINO_JACKPOT_REWARD = 10000;
const SAVE_KEYS = [
  'money',
  'moneyup',
  'msec',
  'upcost',
  'upown',
  'catcost',
  'catadd',
  'catown',
  'cboost',
  'workercost',
  'workadd',
  'workerown',
  'wboost',
  'buildingcost',
  'buildingadd',
  'buildingown',
  'towercost',
  'toweradd',
  'towerown',
  'companycost',
  'companyadd',
  'companyown',
  'bandcost',
  'bandadd',
  'bandown',
] as const;

const generatorConfigs: GeneratorConfig[] = [
  {
    id: 'cat',
    label: 'Clicker Cat',
    description: 'Small paws, steady passive LB.',
    initials: 'CC',
    baseCost: 25,
    basePower: 1,
    costMultiplier: 2,
    maxBonusText: '+15% click/sec',
    tiers: [
      { maxOwned: 14, multiplier: 1 },
      { maxOwned: 24, multiplier: 200 },
      { maxOwned: 49, multiplier: 5000 },
      { maxOwned: Infinity, multiplier: 15000 },
    ],
  },
  {
    id: 'worker',
    label: 'Worker',
    description: 'Reliable production from the floor.',
    initials: 'WK',
    baseCost: 250,
    basePower: 15,
    costMultiplier: 3,
    maxBonusText: '+35% click/sec',
    tiers: [
      { maxOwned: 14, multiplier: 1 },
      { maxOwned: 24, multiplier: 200 },
      { maxOwned: 49, multiplier: 5000 },
      { maxOwned: Infinity, multiplier: 15000 },
    ],
  },
  {
    id: 'building',
    label: 'Building',
    description: 'Turns the clicker into a facility.',
    initials: 'BD',
    baseCost: 50000,
    basePower: 1000,
    costMultiplier: 1000,
    maxBonusText: '+500% click/sec',
    tiers: [
      { maxOwned: 14, multiplier: 1 },
      { maxOwned: 24, multiplier: 20 },
      { maxOwned: 49, multiplier: 500 },
      { maxOwned: Infinity, multiplier: 15000 },
    ],
  },
  {
    id: 'tower',
    label: 'Tower',
    description: 'A taller engine for serious growth.',
    initials: 'TW',
    baseCost: 100000,
    basePower: 5000,
    costMultiplier: 100000,
    maxBonusText: '+50000% click/sec',
    tiers: [
      { maxOwned: 14, multiplier: 1 },
      { maxOwned: 24, multiplier: 200 },
      { maxOwned: 49, multiplier: 500000 },
      { maxOwned: Infinity, multiplier: 150000 },
    ],
  },
  {
    id: 'company',
    label: 'Company',
    description: 'Corporate-grade LB acceleration.',
    initials: 'CO',
    baseCost: 1000000000,
    basePower: 50000,
    costMultiplier: 1000000000000000,
    maxBonusText: '+huge click/sec',
    tiers: [
      { maxOwned: 14, multiplier: 1 },
      { maxOwned: 24, multiplier: 2000 },
      { maxOwned: 49, multiplier: 500000 },
      { maxOwned: Infinity, multiplier: 1500000 },
    ],
  },
  {
    id: 'band',
    label: 'Band',
    description: 'Late-game chaos with loud numbers.',
    initials: 'BN',
    baseCost: 1e22,
    basePower: 100000,
    costMultiplier: 1e23,
    maxBonusText: '+massive click/sec',
    tiers: [
      { maxOwned: 14, multiplier: 1 },
      { maxOwned: 24, multiplier: 2000000000 },
      { maxOwned: 49, multiplier: 500000 },
      { maxOwned: Infinity, multiplier: 1500000000 },
    ],
  },
];

const configById = Object.fromEntries(
  generatorConfigs.map((config) => [config.id, config]),
) as Record<GeneratorId, GeneratorConfig>;

const createInitialGenerators = (): Record<GeneratorId, GeneratorState> =>
  Object.fromEntries(
    generatorConfigs.map((config) => [
      config.id,
      {
        owned: 0,
        cost: config.baseCost,
        power: config.basePower,
        boost: 1,
      },
    ]),
  ) as Record<GeneratorId, GeneratorState>;

const initialGameState: GameState = {
  money: 0,
  perClick: 1,
  perSecond: 0,
  mainUpgradeCost: 15,
  mainUpgradeOwned: 0,
  generators: createInitialGenerators(),
};

const NUMBER_SUFFIXES = ['', 'K', 'M', 'B', 'T', 'Q', 'S'];

const formatNumber = (value: number) => {
  if (!Number.isFinite(value)) {
    return 'MAX';
  }

  const absValue = Math.abs(value);

  if (absValue < 1000) {
    return Math.floor(value).toLocaleString('en-US');
  }

  const suffixIndex = Math.min(Math.floor(Math.log10(absValue) / 3), NUMBER_SUFFIXES.length - 1);

  if (suffixIndex >= NUMBER_SUFFIXES.length - 1 && absValue >= 1e21) {
    return value.toExponential(2).replace('+', '');
  }

  const scaledValue = value / 1000 ** suffixIndex;
  const decimals = Math.abs(scaledValue) >= 100 ? 0 : Math.abs(scaledValue) >= 10 ? 1 : 2;

  return `${scaledValue.toFixed(decimals).replace(/\.0+$|(\.\d*[1-9])0+$/, '$1')}${NUMBER_SUFFIXES[suffixIndex]}`;
};

const isSafeGameNumber = (value: number) => Number.isFinite(value) && value >= 0 && value <= MAX_SAFE_COST;

const canBuyCost = (money: number, cost: number) => isSafeGameNumber(money) && isSafeGameNumber(cost) && money >= cost;

const readNumber = (key: string, fallback: number) => {
  const rawValue = localStorage.getItem(key);
  if (rawValue === null) {
    return fallback;
  }

  const parsed = Number(rawValue);
  return Number.isFinite(parsed) ? parsed : fallback;
};

const getTierMultiplier = (config: GeneratorConfig, owned: number) =>
  config.tiers.find((tier) => owned < tier.maxOwned)?.multiplier ?? 1;

const saveGame = (state: GameState) => {
  localStorage.setItem('money', String(state.money));
  localStorage.setItem('moneyup', String(state.perClick));
  localStorage.setItem('msec', String(state.perSecond));
  localStorage.setItem('upcost', String(state.mainUpgradeCost));
  localStorage.setItem('upown', String(state.mainUpgradeOwned));

  for (const config of generatorConfigs) {
    const generator = state.generators[config.id];
    const legacyPrefix = config.id === 'worker' ? 'worker' : config.id;
    localStorage.setItem(`${legacyPrefix}cost`, String(generator.cost));
    localStorage.setItem(`${legacyPrefix}add`, String(generator.power));
    localStorage.setItem(`${legacyPrefix}own`, String(generator.owned));
  }

  localStorage.setItem('cboost', String(state.generators.cat.boost));
  localStorage.setItem('wboost', String(state.generators.worker.boost));
};

const loadGame = (): GameState => {
  const generators = createInitialGenerators();

  for (const config of generatorConfigs) {
    const legacyPrefix = config.id === 'worker' ? 'worker' : config.id;
    const generator = generators[config.id];
    generator.cost = readNumber(`${legacyPrefix}cost`, generator.cost);
    generator.power = readNumber(`${legacyPrefix}add`, generator.power);
    generator.owned = readNumber(`${legacyPrefix}own`, generator.owned);
    generator.boost = getTierMultiplier(config, generator.owned);
  }

  generators.cat.boost = readNumber('cboost', generators.cat.boost);
  generators.worker.boost = readNumber('wboost', generators.worker.boost);

  return {
    money: readNumber('money', initialGameState.money),
    perClick: readNumber('moneyup', initialGameState.perClick),
    perSecond: readNumber('msec', initialGameState.perSecond),
    mainUpgradeCost: readNumber('upcost', initialGameState.mainUpgradeCost),
    mainUpgradeOwned: readNumber('upown', initialGameState.mainUpgradeOwned),
    generators,
  };
};

const buyGenerator = (state: GameState, id: GeneratorId): GameState => {
  const generator = state.generators[id];
  const config = configById[id];

  if (generator.owned >= MAX_GENERATOR_LEVEL || !canBuyCost(state.money, generator.cost)) {
    return state;
  }

  const boost = getTierMultiplier(config, generator.owned);
  const gainedPerSecond = generator.power * boost;
  const nextPower = generator.power + 1;
  const nextOwned = generator.owned + 1;
  const nextBoost = getTierMultiplier(config, nextOwned);

  return {
    ...state,
    money: state.money - generator.cost,
    perSecond: state.perSecond + gainedPerSecond,
    generators: {
      ...state.generators,
      [id]: {
        owned: nextOwned,
        cost: generator.cost * config.costMultiplier,
        power: nextPower,
        boost: nextBoost,
      },
    },
  };
};

const ProgressRing = ({ value }: { value: number }) => (
  <svg className="progress-ring" viewBox="0 0 42 42" aria-hidden="true">
    <circle className="progress-ring-track" cx="21" cy="21" r="16" />
    <circle className="progress-ring-value" cx="21" cy="21" r="16" style={{ strokeDasharray: `${value} 100` }} />
  </svg>
);

type SlotMachineProps = {
  money: number;
  onSpinResult: (result: string[], reward: number, cost: number) => void;
  onCannotAfford: () => void;
};

const getCasinoReward = (result: string[]) => {
  const uniqueValues = new Set(result);

  if (result.every((slot) => slot === '7')) {
    return CASINO_JACKPOT_REWARD;
  }

  if (uniqueValues.size === 1) {
    return CASINO_THREE_MATCH_REWARD;
  }

  if (uniqueValues.size === 2) {
    return CASINO_TWO_MATCH_REWARD;
  }

  return 0;
};

const SlotMachine = ({ money, onSpinResult, onCannotAfford }: SlotMachineProps) => {
  const values = ['1', '2', '3', '4', '5', '6', '7'];
  const [slots, setSlots] = useState(['1', '2', '3']);
  const [spinning, setSpinning] = useState(false);

  const spin = () => {
    if (spinning) {
      return;
    }

    if (!canBuyCost(money, CASINO_SPIN_COST)) {
      onCannotAfford();
      return;
    }

    setSpinning(true);
    const startedAt = Date.now();
    const interval = window.setInterval(() => {
      const nextSlots = Array.from({ length: 3 }, () => values[Math.floor(Math.random() * values.length)]);
      setSlots(nextSlots);

      if (Date.now() - startedAt > 2000) {
        window.clearInterval(interval);
        const finalSlots = Array.from({ length: 3 }, () => values[Math.floor(Math.random() * values.length)]);
        setSlots(finalSlots);
        onSpinResult(finalSlots, getCasinoReward(finalSlots), CASINO_SPIN_COST);
        setSpinning(false);
      }
    }, 90);
  };

  return (
    <section className="surface casino-card" aria-labelledby="casino-title">
      <div className="panel-heading compact-heading">
        <div>
          <p className="eyebrow" id="casino-title">Casino</p>
          <h2>Lucky side room</h2>
        </div>
        <span className="status-pill">Beta</span>
      </div>

      <div className="slot-machine" aria-label="Slot machine">
        <div className="slot-container">
          {slots.map((slot, index) => (
            <span className="slot" key={`reel-${index}`}>{slot}</span>
          ))}
        </div>
        <p className="casino-rules">
          Cost {formatNumber(CASINO_SPIN_COST)} LB. Two match pays {formatNumber(CASINO_TWO_MATCH_REWARD)}. Three match pays {formatNumber(CASINO_THREE_MATCH_REWARD)}. 777 pays {formatNumber(CASINO_JACKPOT_REWARD)}.
        </p>
        <button className="action-button full" type="button" onClick={spin} disabled={spinning || !canBuyCost(money, CASINO_SPIN_COST)}>
          {spinning ? 'Spinning' : 'Spin'}
        </button>
      </div>
    </section>
  );
};

export default function App() {
  const [game, setGame] = useState<GameState>(() => loadGame());
  const [message, setMessage] = useState('Autosaves when you leave. Manual save is here too.');
  const imageBase = import.meta.env.BASE_URL;

  useEffect(() => {
    const timer = window.setInterval(() => {
      setGame((current) => ({
        ...current,
        money: current.money + current.perSecond,
      }));
    }, 1000);

    return () => window.clearInterval(timer);
  }, []);

  useEffect(() => {
    const handleBeforeUnload = () => saveGame(game);
    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => window.removeEventListener('beforeunload', handleBeforeUnload);
  }, [game]);

  const stats = useMemo(
    () => [
      { label: 'Per click', value: formatNumber(game.perClick), helper: 'Every tap' },
      { label: 'Per second', value: formatNumber(game.perSecond), helper: 'Passive income' },
      { label: 'Upgrades', value: formatNumber(game.mainUpgradeOwned), helper: 'Click power' },
    ],
    [game.mainUpgradeOwned, game.perClick, game.perSecond],
  );

  const totalOwned = useMemo(
    () => generatorConfigs.reduce((total, config) => total + game.generators[config.id].owned, 0),
    [game.generators],
  );

  const handleClick = () => {
    setGame((current) => ({
      ...current,
      money: current.money + current.perClick,
    }));
  };

  const buyMainUpgrade = () => {
    setGame((current) => {
      if (current.mainUpgradeOwned >= MAX_MAIN_UPGRADE_LEVEL || !isSafeGameNumber(current.mainUpgradeCost)) {
        setMessage('Click power is maxed. No more main upgrades can be bought.');
        return current;
      }

      if (!canBuyCost(current.money, current.mainUpgradeCost)) {
        setMessage(`Need ${formatNumber(current.mainUpgradeCost - current.money)} more LB for the main upgrade.`);
        return current;
      }

      setMessage('Main click upgraded. The button has more bite now.');
      return {
        ...current,
        money: current.money - current.mainUpgradeCost,
        perClick: current.perClick + current.mainUpgradeCost / 15,
        mainUpgradeOwned: current.mainUpgradeOwned + 1,
        mainUpgradeCost: Math.min(current.mainUpgradeCost * 5, MAX_SAFE_COST),
      };
    });
  };

  const handleSave = () => {
    saveGame(game);
    setMessage('Saved. Your LB empire is tucked in safely.');
  };

  const handleLoad = () => {
    setGame(loadGame());
    setMessage('Loaded your saved progress.');
  };

  const handleReset = () => {
    if (!window.confirm('Are you sure you want to reset?')) {
      return;
    }

    for (const key of SAVE_KEYS) {
      localStorage.removeItem(key);
    }

    setGame(initialGameState);
    setMessage('Progress reset. Fresh clicker, clean slate.');
  };

  const handleGeneratorBuy = (id: GeneratorId) => {
    setGame((current) => {
      const generator = current.generators[id];
      const config = configById[id];

      if (generator.owned >= MAX_GENERATOR_LEVEL) {
        setMessage(`${config.label} is already maxed.`);
        return current;
      }

      if (!isSafeGameNumber(generator.cost)) {
        setMessage(`${config.label} cost is maxed out and cannot be bought again.`);
        return current;
      }

      if (!canBuyCost(current.money, generator.cost)) {
        setMessage(`Need ${formatNumber(generator.cost - current.money)} more LB for ${config.label}.`);
        return current;
      }

      setMessage(`${config.label} bought. Passive LB is climbing.`);
      return buyGenerator(current, id);
    });
  };

  const handleCasinoResult = (result: string[], reward: number, cost: number) => {
    setGame((current) => ({
      ...current,
      money: current.money - cost + reward,
    }));

    const resultText = result.join('-');

    if (reward === CASINO_JACKPOT_REWARD) {
      setMessage(`Jackpot ${resultText}! You won ${formatNumber(reward)} LB.`);
      return;
    }

    if (reward > 0) {
      setMessage(`${resultText}! Casino paid ${formatNumber(reward)} LB.`);
      return;
    }

    setMessage(`${resultText}. No match, spin cost ${formatNumber(cost)} LB.`);
  };

  const handleCasinoCannotAfford = () => {
    if (!isSafeGameNumber(game.money)) {
      setMessage('Balance is too large or invalid for casino spins.');
      return;
    }

    setMessage(`Need ${formatNumber(CASINO_SPIN_COST - game.money)} more LB to spin.`);
  };

  const showCopyright = () => {
    setMessage('Copyright Never-Wet Clicker.');
  };

  return (
    <main className="app-shell">
      <div className="ambient ambient-one" aria-hidden="true" />
      <div className="ambient ambient-two" aria-hidden="true" />

      <header className="app-header">
        <a className="brand-mark" href="https://junha2010.github.io/" aria-label="Go to Junha home">
          <span>NW</span>
        </a>
        <nav className="header-actions" aria-label="Save controls">
          <button type="button" onClick={handleSave}>Save</button>
          <button type="button" onClick={handleLoad}>Load</button>
          <button type="button" className="danger-link" onClick={handleReset}>Reset</button>
        </nav>
      </header>

      <section className="dashboard-row primary-row">
        <section className="balance-card top-balance" aria-label="Current LB balance">
          <span className="balance-label">Current Balance</span>
          <strong>LB {formatNumber(game.money)}</strong>
          <p aria-live="polite">{message}</p>
        </section>

        <section className="tap-zone surface" aria-labelledby="tap-title">
          <div className="tap-copy">
            <p className="eyebrow" id="tap-title">Tap Core</p>
            <h2>Press the character</h2>
            <p>Each press adds <strong>{formatNumber(game.perClick)} LB</strong>. It is the simplest machine in the room, and somehow still the most dramatic.</p>
          </div>

          <button className="character-button" type="button" onClick={handleClick} aria-label={`Earn ${formatNumber(game.perClick)} LB`}>
            <span className="click-halo" aria-hidden="true" />
            <img src={`${imageBase}img/junha.png`} alt="Never-Wet Clicker character" />
            <span className="click-label">Tap for LB</span>
          </button>

          <div className="stat-strip">
            {stats.map((stat) => (
              <article className="stat-card" key={stat.label}>
                <span>{stat.label}</span>
                <strong>{stat.value}</strong>
                <small>{stat.helper}</small>
              </article>
            ))}
          </div>
        </section>
      </section>

      <section className="dashboard-row utility-row">
        <section className="surface main-upgrade-card">
          <div className="panel-heading compact-heading">
            <div>
              <p className="eyebrow">Main Upgrade</p>
              <h2>Click power</h2>
            </div>
            <ProgressRing value={Math.min(100, (game.mainUpgradeOwned / MAX_MAIN_UPGRADE_LEVEL) * 100)} />
          </div>
          <p className="card-note">Level {formatNumber(game.mainUpgradeOwned)} / {MAX_MAIN_UPGRADE_LEVEL}. Next upgrade increases every tap.</p>
          <button
            className="action-button full"
            type="button"
            onClick={buyMainUpgrade}
            disabled={game.mainUpgradeOwned >= MAX_MAIN_UPGRADE_LEVEL || !canBuyCost(game.money, game.mainUpgradeCost)}
          >
            {game.mainUpgradeOwned >= MAX_MAIN_UPGRADE_LEVEL || !isSafeGameNumber(game.mainUpgradeCost)
              ? 'Click power maxed'
              : `Buy for ${formatNumber(game.mainUpgradeCost)} LB`}
          </button>
        </section>

        <SlotMachine
          money={game.money}
          onCannotAfford={handleCasinoCannotAfford}
          onSpinResult={handleCasinoResult}
        />

        <section className="surface construction-card">
          <p className="eyebrow">Plus Click Area</p>
          <h2>Locked wing</h2>
          <p>Future upgrades can live here without crowding the main shop.</p>
        </section>
      </section>

      <section className="surface upgrades-panel" aria-labelledby="upgrade-title">
        <div className="panel-heading">
          <div>
            <p className="eyebrow" id="upgrade-title">Generator Shop</p>
            <h2>Buy the passive income crew</h2>
          </div>
          <div className="owned-summary">
            <span>{formatNumber(totalOwned)}</span>
            <small>Total owned</small>
          </div>
        </div>

        <div className="upgrade-grid">
          {generatorConfigs.map((config) => {
            const generator = game.generators[config.id];
            const isMaxed = generator.owned >= MAX_GENERATOR_LEVEL;
            const canAfford = canBuyCost(game.money, generator.cost);
            const costIsSafe = isSafeGameNumber(generator.cost);
            const nextGain = generator.power * generator.boost;
            const progress = Math.min(100, (generator.owned / MAX_GENERATOR_LEVEL) * 100);

            return (
              <article className={`upgrade-card theme-${config.id}`} key={config.id}>
                <div className="upgrade-topline">
                  <span className="upgrade-icon" aria-hidden="true">{config.initials}</span>
                  <div>
                    <h3>{config.label}</h3>
                    <p>{config.description}</p>
                  </div>
                </div>

                <div className="upgrade-meter" aria-label={`${config.label} level ${generator.owned} of ${MAX_GENERATOR_LEVEL}`}>
                  <span style={{ width: `${progress}%` }} />
                </div>

                <dl className="upgrade-meta">
                  <div>
                    <dt>Owned</dt>
                    <dd>{formatNumber(generator.owned)} / {MAX_GENERATOR_LEVEL}</dd>
                  </div>
                  <div>
                    <dt>Next gain</dt>
                    <dd>{isMaxed ? config.maxBonusText : `+${formatNumber(nextGain)}/sec`}</dd>
                  </div>
                </dl>

                <button
                  className="buy-button"
                  type="button"
                  onClick={() => handleGeneratorBuy(config.id)}
                  disabled={isMaxed || !canAfford}
                >
                  <span>{isMaxed || !costIsSafe ? 'Maxed' : canAfford ? 'Buy upgrade' : 'Need more LB'}</span>
                  <strong>{isMaxed || !costIsSafe ? 'MAX' : `${formatNumber(generator.cost)} LB`}</strong>
                </button>
              </article>
            );
          })}
        </div>
      </section>

      <footer className="site-footer">
        <a href="https://junha2010.github.io/">Home</a>
        <button type="button" onClick={showCopyright}>Copyright</button>
      </footer>
    </main>
  );
}
