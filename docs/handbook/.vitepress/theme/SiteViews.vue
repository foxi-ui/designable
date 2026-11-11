<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(
  defineProps<{
    variant?: 'footer' | 'hero'
    withIds?: boolean
    mirror?: boolean
  }>(),
  {
    variant: 'footer',
    withIds: false,
    mirror: false,
  }
)

const sitePvId = computed(() =>
  props.withIds ? 'vercount_value_site_pv' : undefined
)
const siteUvId = computed(() =>
  props.withIds ? 'vercount_value_site_uv' : undefined
)
const sitePvMirror = computed(() => (props.mirror ? 'site_pv' : undefined))
const siteUvMirror = computed(() => (props.mirror ? 'site_uv' : undefined))
</script>

<template>
  <p class="vercount-site-views" :class="`vercount-site-views--${variant}`">
    全站累计浏览
    <span :id="sitePvId" :data-vercount-mirror="sitePvMirror">…</span>
    次 · 约
    <span :id="siteUvId" :data-vercount-mirror="siteUvMirror">…</span>
    位访客
  </p>
</template>
