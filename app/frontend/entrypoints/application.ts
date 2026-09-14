import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { registry } from '~/components/registry'

// Rails views mark where a component goes with `vue_component` (app/helpers/vue_helper.rb):
//   <div data-vue="CourtBookingApp" data-props="{...}">fallback markup</div>
// Each mount point becomes its own small Vue app, so pages that have not moved to Vue yet are
// left exactly as they were.

async function mountElement(el: HTMLElement): Promise<void> {
  if (el.dataset.vueMounted) return

  const name = el.dataset.vue ?? ''
  const load = registry[name]
  if (!load) {
    console.error(`[vue] no component registered as "${name}"`)
    return
  }

  el.dataset.vueMounted = 'true'
  const props: Record<string, unknown> = el.dataset.props ? JSON.parse(el.dataset.props) : {}
  const { default: component } = await load()
  createApp(component, props).use(createPinia()).mount(el)
}

export function mountVueComponents(root: ParentNode = document): void {
  root.querySelectorAll<HTMLElement>('[data-vue]').forEach((el) => {
    void mountElement(el)
  })
}

// Markup injected later by a jQuery `.js.erb` response can call this to mount what it added.
declare global {
  interface Window {
    mountVueComponents: typeof mountVueComponents
  }
}
window.mountVueComponents = mountVueComponents

mountVueComponents()
