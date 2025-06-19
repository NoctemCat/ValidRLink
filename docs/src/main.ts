import './assets/main.css';
import '@fontsource/inter/400.css';

import { createApp } from 'vue';
import { createPinia } from 'pinia';
import { createI18n } from 'vue-i18n';

import App from './App.vue';
import router from './router';

const i18n = createI18n({
    legacy: false,
    fallbackLocale: 'en',
    messages: {
        en: {
            message: {
                hello: 'hello world',
            },
        },
        ru: {
            message: {
                hello: 'привет мир',
            },
        },
    },
});

const app = createApp(App);

app.use(createPinia());
app.use(i18n);
app.use(router);

router.isReady().then(() => {
    app.mount('#app');
});
