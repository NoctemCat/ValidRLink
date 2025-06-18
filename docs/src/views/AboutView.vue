<script setup lang="ts">
import { useI18n } from 'vue-i18n';
const { t } = useI18n({
    useScope: 'local',
});
</script>

<template>
    <div class="about">
        <h1>{{ t('about') }}</h1>
        <h1>{{ t('text') }}</h1>
    </div>
</template>

<style>
@media (min-width: 1024px) {
    .about {
        min-height: 100vh;
        display: flex;
        align-items: center;
        flex-direction: column;
        justify-content: center;
    }
}
</style>

<i18n locale="en">
{
  "about": "This is an about page",
  "text": "More custom text",
}
</i18n>

<i18n locale="ru">
{
  "about": "Это страница про нас",
  "text": "Больше своего текста",
}
</i18n>
