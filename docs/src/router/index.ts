import { createRouter, createWebHistory } from 'vue-router';

import HomeView from '../views/HomeView.vue';
// import LangView from '@/LangView.vue';
// import { useI18n } from 'vue-i18n';

const GetPreferredPath = (enPath: object, ruPath: object) => {
    if (navigator.languages.length <= 0) {
        return enPath;
    }
    for (const lang of navigator.languages) {
        if (lang == 'en' || lang.startsWith('en-')) {
            return enPath;
        }
        if (lang == 'ru' || lang == 'ru-RU') {
            return ruPath;
        }
    }
    return enPath;
};

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/',
            redirect: () => GetPreferredPath({ path: '/en/' }, { path: '/ru/' }),
        },
        {
            path: '/:path',
            redirect: (to) => {
                const enPath = { path: '/en/'.concat(to.params.path as string) };
                const ruPath = { path: '/ru/'.concat(to.params.path as string) };
                return GetPreferredPath(enPath, ruPath);
            },
        },
        {
            path: '/:lang(en|ru)',
            children: [
                {
                    path: '',
                    name: 'home',
                    component: HomeView,
                },
                {
                    path: 'about',
                    name: 'about',
                    component: () => import('../views/AboutView.vue'),
                },
            ],
        },
    ],
});

export default router;
