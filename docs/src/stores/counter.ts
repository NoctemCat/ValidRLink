import { computed, ref, watchEffect } from 'vue';
import { defineStore } from 'pinia';
import { usePreferredDark } from '@vueuse/core';
import { useRoute } from 'vue-router';

export const useModeStore = defineStore('counter', () => {
    const route = useRoute();

    const mode = ref(usePreferredDark() ? 'dark' : 'light');

    const preferredMode = computed(() => (usePreferredDark() ? 'dark' : 'light'));
    const isDark = computed(() => {
        return mode.value == 'dark';
    });
    const isDifferentFromPreferred = computed(() => {
        return mode.value != preferredMode.value;
    });
    const setMode = (newMode: string) => {
        mode.value = newMode;
    };

    watchEffect(() => {
        if (route.query.mode == 'light' || route.query.mode == 'dark') {
            mode.value = route.query.mode;
        }
    });
    return { mode, isDark, isDifferentFromPreferred, setMode };
});
