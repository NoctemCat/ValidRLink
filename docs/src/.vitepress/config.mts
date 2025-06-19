import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
    title: "ValidRLink Docs",
    description: "Plugin for Godot",

    themeConfig: {
        logo: "/logo.svg",
        // https://vitepress.dev/reference/default-theme-config
        nav: [
            { text: "Home", link: "/" },
            { text: "Examples", link: "/markdown-examples" },
        ],

        sidebar: [
            {
                text: "Examples",
                items: [
                    { text: "Markdown Examples", link: "/markdown-examples" },
                    { text: "Runtime API Examples", link: "/api-examples" },
                ],
            },
        ],

        socialLinks: [
            { icon: "github", link: "https://github.com/NoctemCat/ValidRLink" },
        ],
    },
    locales: {
        root: {
            label: "English",
            lang: "en",
        },
        ru: {
            label: "Русский",
            lang: "ru",

            themeConfig: {
                nav: [
                    { text: "Home", link: "/" },
                    { text: "Examples", link: "/ru/markdown-examples" },
                ],

                sidebar: [
                    {
                        text: "Examples",
                        items: [
                            {
                                text: "Markdown Examples",
                                link: "/ru/markdown-examples",
                            },
                            {
                                text: "Runtime API Examples",
                                link: "/ru/api-examples",
                            },
                        ],
                    },
                ],
            },
        },
    },

    head: [
        [
            "link",
            {
                rel: "icon",
                type: "image/png",
                href: "/favicon-96x96.png",
                sizes: "96x96",
            },
        ],
        [
            "link",
            {
                rel: "icon",
                type: "image/svg+xml",
                href: "/favicon.svg",
            },
        ],
        [
            "link",
            {
                rel: "shortcut icon",
                href: "/favicon.svg",
            },
        ],
        [
            "link",
            {
                rel: "apple-touch-icon",
                sizes: "180x180",
                href: "/apple-touch-icon.png",
            },
        ],
        [
            "link",
            {
                rel: "manifest",
                href: "/site.webmanifest",
            },
        ],
    ],
});
