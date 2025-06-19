import { fileURLToPath, URL } from 'node:url';

import { defineConfig, HtmlTagDescriptor } from 'vite';
import vue from '@vitejs/plugin-vue';
import vueDevTools from 'vite-plugin-vue-devtools';
import VueI18nPlugin from '@intlify/unplugin-vue-i18n/vite';
import UnheadVite from '@unhead/addons/vite';

import { type OutputChunk, type OutputAsset } from 'rollup';
// import '@fontsource-variable/open-sans';
// import openSansWoff2 from '@fontsource-variable/open-sans/files/open-sans-latin-wght-normal.woff2?url';
// import '@fontsource/inter';http://localhost:5173/ValidRLink/node_modules/@fontsource/inter/files/inter-cyrillic-400-normal.woff2
// import interWoff2 from '@fontsource/inter/files/inter-cyrillic-400-normal.woff2?url';

// http://localhost:5173/ValidRLink/node_modules/@fontsource/inter/files/inter-cyrillic-400-normal.woff2
// node_modules/@fontsource/inter/files/inter-cyrillic-400-normal.woff2
// https://vite.dev/config/
export default defineConfig({
    base: '/ValidRLink/',
    plugins: [
        vue(),
        vueDevTools(),
        VueI18nPlugin(),
        UnheadVite(),
        {
            name: 'vite-resolve-font-preload',

            transformIndexHtml: {
                order: 'post',

                handler: (_, ctx) => {
                    const isAsset = (bundle: OutputAsset | OutputChunk): bundle is OutputAsset => {
                        return (<OutputAsset>bundle).source !== undefined;
                    };
                    const isString = (
                        source: string | Uint8Array<ArrayBufferLike>,
                    ): source is string => {
                        return (<string>source).match !== undefined;
                    };

                    const tags: HtmlTagDescriptor[] = [];
                    if (ctx.bundle != null) {
                        const re = /src:url\((.+?)\)\s+format\(\"woff2\"\)/g;
                        for (const [k, v] of Object.entries(ctx.bundle)) {
                            if (k.endsWith('.css') && isAsset(v) && isString(v.source)) {
                                let m: RegExpExecArray | null;
                                while ((m = re.exec(v.source))) {
                                    if (m[1].includes('inter')) {
                                        tags.push({
                                            injectTo: 'head-prepend',
                                            tag: 'link',
                                            attrs: {
                                                rel: 'preload',
                                                as: 'font',
                                                type: 'font/woff2',
                                                href: m[1],
                                                // crossorigin: 'anonymous',
                                            },
                                        });
                                    }
                                }
                            }
                            // if (
                            //     k.includes('inter') &&
                            //     k.endsWith('.woff2') &&
                            //     (k.includes('latin') || k.includes('cyrillic'))
                            // ) {
                            //     console.log(v);
                            //     // tags.push({
                            //     //     injectTo: 'head-prepend',
                            //     //     tag: 'link',
                            //     //     attrs: {
                            //     //         rel: 'preload',
                            //     //         as: 'font',
                            //     //         type: 'font/woff2',
                            //     //         href: `/ValidRLink/${v.fileName}`,
                            //     //     },
                            //     // });
                            // }
                        }
                    }
                    return tags;
                },
            },
        },
    ],
    resolve: {
        alias: {
            '@': fileURLToPath(new URL('./src', import.meta.url)),
        },
    },
});
