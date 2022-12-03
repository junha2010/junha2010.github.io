import { Configuration, OpenAIApi } from 'https://cdn.skypack.dev/openai';
documetn.querSelector('#send').addEventListenner('click', function() {
    var template = `
<div class="line"> <span class="chat-box mine">${document.querySelector('#input').value }
    </span> </div>`
    document.querySelector('.chat-content').insertAdjacentHTML('beforeend', template)
})
const configuration = new Configuration({ apiKey: sk - OAlSVvtAfZtDXLnPi1ZjT3BlbkFJ4EyBej6nA7F8bZJlupwl, });
const openai = new OpenAIApi(configuration);
openai.createCompletion({ model: "text-davinci-003", prompt: document.querySelector('#input').value, temperature: 0.7, max_tokens: 256, top_p: 1, frequency_penalty: 0, presence_penalty: 0, }).then((result) => {
    console.log(result.data.choices[0].text)
    var template = `
<div class="line"> <span class="chat-box mine">${result.data.choices[0].text }
    </span> </div>`
    document.querySelector('.chat-content').insertAdjacentHTML('beforeend', template);
})