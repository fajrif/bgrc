<script setup lang="ts">
import { nextTick, onBeforeUnmount, onMounted, ref, useId, watch } from 'vue'

// Reuses the site's Bootstrap + bbcc-modal styling but not Bootstrap's JavaScript, so open/close
// state lives in Vue instead of being toggled behind its back by `new bootstrap.Modal`.

const props = withDefaults(
  defineProps<{
    open: boolean
    title: string
    size?: 'md' | 'lg'
    dismissible?: boolean
  }>(),
  { size: 'md', dismissible: true },
)

const emit = defineEmits<{ close: [] }>()

const titleId = useId()
const dialog = ref<HTMLElement | null>(null)

function requestClose(): void {
  if (props.dismissible) emit('close')
}

function onKeydown(event: KeyboardEvent): void {
  if (event.key === 'Escape') requestClose()
}

function setOpen(open: boolean): void {
  document.body.classList.toggle('modal-open', open)
  if (open) {
    document.addEventListener('keydown', onKeydown)
    void nextTick(() => dialog.value?.focus())
  } else {
    document.removeEventListener('keydown', onKeydown)
  }
}

watch(() => props.open, setOpen)
onMounted(() => {
  if (props.open) setOpen(true)
})
onBeforeUnmount(() => {
  if (props.open) setOpen(false)
})
</script>

<template>
  <Teleport to="body">
    <template v-if="open">
      <div
        ref="dialog"
        class="modal fade show bbcc-modal d-block"
        tabindex="-1"
        role="dialog"
        aria-modal="true"
        :aria-labelledby="titleId"
        @click.self="requestClose"
      >
        <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable" :class="{ 'modal-lg': size === 'lg' }">
          <div class="modal-content">
            <div class="modal-header">
              <h2 :id="titleId" class="bbcc-modal-title">{{ title }}</h2>
              <button v-if="dismissible" type="button" class="bbcc-modal-close" aria-label="Close" @click="requestClose">
                <i class="fa-solid fa-xmark" aria-hidden="true"></i>
              </button>
            </div>
            <div class="modal-body">
              <slot />
            </div>
            <div v-if="$slots.footer" class="modal-footer">
              <slot name="footer" />
            </div>
          </div>
        </div>
      </div>
      <div class="modal-backdrop fade show"></div>
    </template>
  </Teleport>
</template>
