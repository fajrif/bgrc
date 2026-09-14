// Same output as the Rails views' `number_to_currency(x, unit: "Rp. ", separator: ",",
// delimiter: ".", precision: 0)`, so a price reads identically whether ERB or Vue rendered it.
export function formatRupiah(amount: number | string | null | undefined): string {
  const rounded = Math.round(Number(amount) || 0)
  const digits = Math.abs(rounded)
    .toString()
    .replace(/\B(?=(\d{3})+(?!\d))/g, '.')
  return `${rounded < 0 ? '-' : ''}Rp. ${digits}`
}
