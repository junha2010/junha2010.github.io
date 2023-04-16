var webData=[
    {tag: "MINECRAFT", url: "https://launcher.mojang.com/download/MinecraftInstaller.exe"},
    {tag: "마인크래프트", url: "https://launcher.mojang.com/download/MinecraftInstaller.exe"},
    {tag: "VALORANT", url: "https://valorant.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.live.ap.exe"},
    {tag: "발로란트", url: "https://valorant.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.live.ap.exe"},
    ];

function doSearch(x){
    for(n = 0; n <webData.length; n++){
        if(x == webData[n].tag){
            document.write('<a href=" ' + webData[n].url + ' ">' + webData[n].url + '</a>')
        }
    }
}
