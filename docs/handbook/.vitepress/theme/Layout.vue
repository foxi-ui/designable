<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { onContentUpdated, useData, useRoute } from 'vitepress'

const { frontmatter } = useData()
const route = useRoute()
const open = ref(false)
const contentHasOutline = ref(false)

const hasOutline = computed(
  () =>
    contentHasOutline.value &&
    frontmatter.value.layout !== 'home' &&
    frontmatter.value.aside !== false &&
    frontmatter.value.outline !== false
)

const syncOutlinePresence = () => {
  if (typeof window === 'undefined') return
  requestAnimationFrame(() => {
    contentHasOutline.value = !!document.querySelector(
      '.VPDocAsideOutline.has-outline'
    )
    document
      .querySelector('.VPDoc .aside')
      ?.setAttribute('id', 'designable-page-outline')
    if (!contentHasOutline.value && open.value) open.value = false
  })
}

onContentUpdated(syncOutlinePresence)

const apply = (value: boolean) => {
  document.documentElement.classList.toggle('outline-open', value)
}

const close = () => {
  open.value = false
}

const onKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') close()
}

onMounted(() => {
  apply(open.value)
  syncOutlinePresence()
  document.addEventListener('keydown', onKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', onKeydown)
})

watch(open, apply)
watch(() => route.path, close)
</script>

<template>
  <DefaultTheme.Layout>
    <template #aside-outline-before>
      <div class="outline-panel-actions">
        <button
          class="outline-close"
          type="button"
          aria-label="关闭本页目录"
          title="关闭"
          @click="close"
        >
          <svg
            viewBox="0 0 16 16"
            fill="none"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            aria-hidden="true"
          >
            <path d="M4 4l8 8M12 4l-8 8" />
          </svg>
        </button>
      </div>
    </template>
  </DefaultTheme.Layout>

  <Teleport to="body">
    <div v-if="open" class="outline-backdrop" @click="close" />
    <button
      v-if="hasOutline"
      class="outline-fab"
      type="button"
      :aria-expanded="open"
      aria-controls="designable-page-outline"
      :title="open ? '收起本页目录' : '打开本页目录'"
      @click="open = !open"
    >
      <svg
        v-if="!open"
        viewBox="0 0 16 16"
        fill="none"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-linecap="round"
        aria-hidden="true"
      >
        <path d="M3 4h10M3 8h10M3 12h6" />
      </svg>
      <svg
        v-else
        viewBox="0 0 16 16"
        fill="none"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-linecap="round"
        aria-hidden="true"
      >
        <path d="M4 4l8 8M12 4l-8 8" />
      </svg>
      <span>{{ open ? '收起目录' : '本页目录' }}</span>
    </button>
  </Teleport>
</template>
