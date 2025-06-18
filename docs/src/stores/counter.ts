import { computed } from 'vue';
import { defineStore } from 'pinia';
import { usePreferredDark } from '@vueuse/core';
import { useRoute } from 'vue-router';

export const useModeStore = defineStore('counter', () => {
    const route = useRoute();
    const mode = computed(() => {
        if (route.query.mode == 'dark' || route.query.mode == 'light') {
            return route.query.mode;
        }
        return usePreferredDark() ? 'dark' : 'light';
    });
    return { mode };
});
