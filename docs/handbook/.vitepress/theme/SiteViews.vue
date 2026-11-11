<script setup lang="ts">
import LoadingDots from './LoadingDots.vue'
</script>

<template>
  <p class="vercount-site-views">
    全站累计浏览
    <span id="vercount_value_site_pv"><LoadingDots /></span>
    次 · 约
    <span id="vercount_value_site_uv"><LoadingDots /></span>
    位访客
  </p>
</template>
