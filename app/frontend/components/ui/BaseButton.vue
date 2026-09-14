<script setup lang="ts">
withDefaults(
  defineProps<{
    variant?: 'primary' | 'light'
    size?: 'md' | 'sm'
    block?: boolean
    type?: 'button' | 'submit'
    disabled?: boolean
    loading?: boolean
  }>(),
  { variant: 'primary', size: 'md', block: false, type: 'button', disabled: false, loading: false },
)
</script>

<template>
  <button
    :type="type"
    class="bbcc-btn"
    :class="{
      'bbcc-btn-light': variant === 'light',
      'bbcc-btn-sm': size === 'sm',
      'bbcc-btn-block': block,
    }"
    :disabled="disabled || loading"
    :aria-busy="loading || undefined"
  >
    <slot />
  </button>
</template>
