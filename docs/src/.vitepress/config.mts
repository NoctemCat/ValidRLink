import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
    title: "ValidRLink Docs",
    description: "Plugin for Godot",
    base: "/ValidRLink/",

    themeConfig: {
        logo: "/logo.svg",
        search: {
            provider: "local",
            options: {
                locales: {
                    ru: {
                        translations: {
                            button: {
                                buttonText: "Поиск",
                                buttonAriaLabel: "Поиск",
                            },
                            modal: {
                                displayDetails: "Отобразить подробный список",
                                resetButtonTitle: "Сбросить поиск",
                                backButtonTitle: "Закрыть поиск",
                                noResultsText: "Нет результатов по запросу",
                                footer: {
                                    selectText: "выбрать",
                                    selectKeyAriaLabel: "выбрать",
                                    navigateText: "перейти",
                                    navigateUpKeyAriaLabel: "стрелка вверх",
                                    navigateDownKeyAriaLabel: "стрелка вниз",
                                    closeText: "закрыть",
                                    closeKeyAriaLabel: "esc",
                                },
                            },
                        },
                    },
                },
            },
        },

        nav: [
            { text: "Home", link: "/" },
            { text: "Docs", link: "/introduction" },
        ],

        sidebar: [
            {
                text: "Setup",
                collapsed: false,
                items: [
                    { text: "Introduction", link: "/introduction" },
                    { text: "Installation", link: "/installation" },
                ],
            },
            {
                text: "Usage",
                collapsed: false,
                items: [
                    { text: "Basic Usage", link: "/usage/" },
                    {
                        text: "How it works?",
                        link: "/usage/how_it_works",
                    },
                    { text: "Limitations", link: "/usage/limitations" },
                    { text: "Plugin Settings", link: "/usage/plugin_settings" },
                    { text: "Local Settings", link: "/usage/local_settings" },
                ],
            },
            {
                text: "Classes",
                items: [
                    {
                        text: "GDScript Classes",
                        collapsed: false,
                        items: [
                            { text: "RLink", link: "/gdscript/rlink" },
                            {
                                text: "RLinkButton",
                                link: "/gdscript/rlink_button",
                            },
                            {
                                text: "RLinkSetting",
                                link: "/gdscript/rlink_settings",
                            },
                        ],
                    },
                    {
                        text: "C# Classes",
                        collapsed: false,
                        items: [
                            { text: "RLinkCS", link: "/csharp/RLinkCS" },
                            {
                                text: "RLinkButtonCS",
                                link: "/csharp/RLinkButtonCS",
                            },
                            {
                                text: "RLinkSettingCS",
                                link: "/csharp/RLinkSettingsCS",
                            },
                        ],
                    },
                ],
            },
        ],

        socialLinks: [
            { icon: "github", link: "https://github.com/NoctemCat/ValidRLink" },
        ],

        footer: {
            message:
                'Released under the <a href="https://github.com/NoctemCat/ValidRLink/blob/main/LICENSE">MIT License</a>',
            copyright:
                'Copyright © 2025 <a href="https://github.com/NoctemCat">NoctemCat</a>',
        },
    },

    locales: {
        root: {
            label: "English",
            lang: "en",
        },
        // ru: {
        //     label: "Русский",
        //     lang: "ru",

        //     themeConfig: {
        //         nav: [
        //             { text: "Home", link: "/" },
        //             { text: "Examples", link: "/ru/markdown-examples" },
        //         ],

        //         sidebar: [
        //             {
        //                 text: "Examples",
        //                 items: [
        //                     {
        //                         text: "Markdown Examples",
        //                         link: "/ru/markdown-examples",
        //                     },
        //                     {
        //                         text: "Runtime API Examples",
        //                         link: "/ru/api-examples",
        //                     },
        //                 ],
        //             },
        //         ],
        //     },
        // },
    },

    head: [
        [
            "link",
            {
                rel: "icon",
                type: "image/png",
                href: "/ValidRLink/favicon-96x96.png",
                sizes: "96x96",
            },
        ],
        [
            "link",
            {
                rel: "icon",
                type: "image/svg+xml",
                href: "/ValidRLink/favicon.svg",
            },
        ],
        [
            "link",
            {
                rel: "shortcut icon",
                href: "/ValidRLink/favicon.svg",
            },
        ],
        [
            "link",
            {
                rel: "apple-touch-icon",
                sizes: "180x180",
                href: "/ValidRLink/apple-touch-icon.png",
            },
        ],
        [
            "link",
            {
                rel: "manifest",
                href: "/ValidRLink/site.webmanifest",
            },
        ],
    ],
});
