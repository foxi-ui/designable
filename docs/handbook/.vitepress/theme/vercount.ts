/**
 * Vercount (https://vercount.one) integration for the handbook.
 *
 * The official embed script only counts the initial document load, while
 * VitePress navigates client-side. We therefore keep Vercount's script and
 * `vercount_value_*` IDs (see `config.ts` and the view components) and reload
 * the script once per route change so every article view is counted.
 */
import { nextTick, onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vitepress'

const SCRIPT_ID = 'vercount-script'
const SCRIPT_SRC = 'https://events.vercount.one/js'
const COUNTER_ID_PREFIX = 'vercount_value_'

const reloadScript = () => {
  if (typeof document === 'undefined') return

  document.getElementById(SCRIPT_ID)?.remove()

  const script = document.createElement('script')
  script.id = SCRIPT_ID
  script.src = SCRIPT_SRC
  script.defer = true
  document.head.appendChild(script)
}

const formatCounter = (element: Element) => {
  const raw = element.textContent?.trim()

  if (!raw || !/^\d+$/.test(raw)) return

  const formatted = Number(raw).toLocaleString('zh-CN')
  if (formatted !== raw) element.textContent = formatted
}

/**
 * The hero line lives above the footer in the DOM, so it cannot share the
 * `vercount_value_*` IDs (Vercount updates a single element per ID). Mirror the
 * footer values into the hero line instead.
 */
const syncMirrors = () => {
  const mirrors = [
    ['site_pv', 'vercount_value_site_pv'],
    ['site_uv', 'vercount_value_site_uv'],
  ] as const

  for (const [key, id] of mirrors) {
    const value = document.getElementById(id)?.textContent
    if (value == null) continue

    document
      .querySelectorAll(`[data-vercount-mirror="${key}"]`)
      .forEach((element) => {
        if (element.textContent !== value) element.textContent = value
      })
  }
}

/**
 * Vercount writes raw integers into the `vercount_value_*` spans. Reformat them
 * with thousands separators, both for values already rendered and for later
 * updates from each script reload.
 */
const observeCounters = () => {
  const formatAll = () => {
    document
      .querySelectorAll(`[id^="${COUNTER_ID_PREFIX}"]`)
      .forEach(formatCounter)
    syncMirrors()
  }

  const observer = new MutationObserver((mutations) => {
    let shouldSync = false

    for (const mutation of mutations) {
      const element =
        mutation.type === 'characterData'
          ? mutation.target.parentElement
          : (mutation.target as Element)

      if (
        element instanceof HTMLElement &&
        element.id.startsWith(COUNTER_ID_PREFIX)
      ) {
        formatCounter(element)
        shouldSync = true
      }
    }

    if (shouldSync) syncMirrors()
  })

  observer.observe(document.body, {
    subtree: true,
    childList: true,
    characterData: true,
  })

  formatAll()

  return observer
}

/**
 * Call once from the persistent theme layout.
 */
export const useVercount = () => {
  const route = useRoute()
  let observer: MutationObserver | null = null

  onMounted(() => {
    observer = observeCounters()
  })

  onUnmounted(() => {
    observer?.disconnect()
  })

  watch(
    () => route.path,
    async () => {
      // Let VitePress render the new page before mirroring values into the
      // hero line and letting the script cache its spans.
      await nextTick()
      syncMirrors()
      reloadScript()
    },
    { flush: 'post' }
  )
}
