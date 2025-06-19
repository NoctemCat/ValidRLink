<script setup lang="ts">
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router';
import HelloWorld from './components/HelloWorld.vue';
import { useI18n } from 'vue-i18n';
import { watchEffect } from 'vue';
import { useModeStore } from './stores/counter';
import { storeToRefs } from 'pinia';

const route = useRoute();
const router = useRouter();
const { locale } = useI18n({ useScope: 'global' });

const modeStore = useModeStore();
const { mode, isDark, isDifferentFromPreferred } = storeToRefs(modeStore);
const { setMode } = modeStore;

watchEffect(() => {
    locale.value = route.params.lang as string;
});
watchEffect(() => {
    if (isDifferentFromPreferred.value) {
        router.replace({ ...route, query: { ...route.query, mode: mode.value } });
    } else {
        router.replace({ ...route, query: { ...route.query, mode: undefined } });
    }
});
watchEffect(() => {
    if (isDark.value) {
        document.body.classList.add('dark');
    } else if (document.body.classList.contains('dark')) {
        document.body.classList.remove('dark');
    }
});
</script>

<template>
    <header>
        <img alt="ValidRLink logo" class="logo" src="@/assets/logo.svg" width="125" height="125" />

        <div class="wrapper">
            <HelloWorld :msg="'You did it! ' + mode" />

            <nav>
                <RouterLink :to="{ name: 'home' }">Home</RouterLink>
                <RouterLink :to="{ name: 'about' }">About</RouterLink>
                <RouterLink :to="{ params: { lang: 'en' } }">En</RouterLink>
                <RouterLink :to="{ params: { lang: 'ru' } }">Ru</RouterLink>
                <a @click="setMode('dark')">Dark</a>
                <a @click="setMode('light')">Light</a>
            </nav>
        </div>
    </header>

    <RouterView />
</template>

<style scoped>
header {
    line-height: 1.5;
    max-height: 100vh;
}

.logo {
    display: block;
    margin: 0 auto 2rem;
}

nav {
    width: 100%;
    font-size: 12px;
    text-align: center;
    margin-top: 2rem;
}

nav a.router-link-exact-active {
    color: var(--color-text);
}

nav a.router-link-exact-active:hover {
    background-color: transparent;
}

nav a {
    display: inline-block;
    padding: 0 1rem;
    border-left: 1px solid var(--color-border);
}

nav a:first-of-type {
    border: 0;
}

@media (min-width: 1024px) {
    header {
        display: flex;
        place-items: center;
        padding-right: calc(var(--section-gap) / 2);
    }

    .logo {
        margin: 0 2rem 0 0;
    }

    header .wrapper {
        display: flex;
        place-items: flex-start;
        flex-wrap: wrap;
    }

    nav {
        text-align: left;
        margin-left: -1rem;
        font-size: 1rem;

        padding: 1rem 0;
        margin-top: 1rem;
    }
}
</style>
