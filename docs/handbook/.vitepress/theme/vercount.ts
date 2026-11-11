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
 * Vercount writes raw integers into the `vercount_value_*` spans. Reformat them
 * with thousands separators, both for values already rendered and for later
 * updates from each script reload.
 */
const observeCounters = () => {
  const formatAll = () => {
    document
      .querySelectorAll(`[id^="${COUNTER_ID_PREFIX}"]`)
      .forEach(formatCounter)
  }

  const observer = new MutationObserver((mutations) => {
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
      }
    }
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
      // Let VitePress render the new page before the script caches its spans.
      await nextTick()
      reloadScript()
    },
    { flush: 'post' }
  )
}
