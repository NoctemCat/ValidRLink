<script setup lang="ts">
// import TheWelcome from '../components/TheWelcome.vue';

import { useI18n } from 'vue-i18n';
const { t } = useI18n();
</script>

<template>
    <main>
        <h1>{{ t('message.hello') }}</h1>
    </main>
</template>
