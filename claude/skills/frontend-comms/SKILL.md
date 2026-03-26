---
name: frontend-comms
description: Technical communication protocol for delegating frontend tasks. Use when sending work to the frontend agent — replaces vague descriptions with precise Vue 3, Tailwind, and shadcn/Basecoat terminology. Triggers when about to send a message to the frontend teammate, dispatch frontend work, or build UI components.
---

# Frontend Technical Communication Protocol

When delegating to the frontend agent, use precise technical vocabulary instead of descriptive language. Frontend executes faster when instructions are unambiguous.

## Rule

**Never describe what something should look like. Specify what it IS.**

Bad: "Make a card that shows car information with a nice layout"
Good: "`<Card>` with `<CardHeader>` + `<CardContent>`. Grid `grid-cols-2 gap-4 md:grid-cols-3`. Props: `:car="Car"` from `@/shared/types`. Slot default for actions."

## Vue 3 Vocabulary

Use these terms exactly:

| Instead of | Say |
|---|---|
| "a reusable piece" | composable (`use___`) |
| "save data" | `ref()` / `reactive()` — specify which |
| "calculated value" | `computed()` |
| "when X changes do Y" | `watch()` / `watchEffect()` |
| "pass data down" | prop (`:propName`) — specify type |
| "send event up" | emit (`@eventName`) — specify payload type |
| "share across components" | `provide/inject` with InjectionKey |
| "page" | route view (`views/module/PageName.vue`) |
| "piece of the page" | component — specify path (`shared/components/` or `features/module/components/`) |
| "popup" | `<Dialog>` / `<Sheet>` / `<Popover>` — specify which |
| "form field" | `<FormField>` + `<FormItem>` + `<FormControl>` — specify input type |
| "list" | `v-for` with `:key` — specify key field |
| "show/hide" | `v-if` / `v-show` — specify condition |
| "loading state" | `<Skeleton>` / spinner / `v-if="isLoading"` |

## Tailwind Vocabulary

Always specify utilities, not visual descriptions:

| Instead of | Say |
|---|---|
| "some spacing" | `p-4` / `gap-6` / `space-y-3` — exact values |
| "centered" | `flex items-center justify-center` or `mx-auto` |
| "responsive" | breakpoint prefix: `sm:` `md:` `lg:` `xl:` |
| "side by side" | `flex gap-4` or `grid grid-cols-2` |
| "stacked on mobile" | `flex flex-col md:flex-row` |
| "rounded corners" | `rounded-lg` / `rounded-xl` / `rounded-full` |
| "shadow" | `shadow-sm` / `shadow-md` / `shadow-lg` |
| "subtle background" | `bg-muted` / `bg-accent` / `bg-card` |
| "text colors" | `text-foreground` / `text-muted-foreground` / `text-primary` |
| "full width on mobile" | `w-full md:w-auto` |
| "nice hover" | `hover:bg-accent transition-colors` |
| "a line between items" | `divide-y` / `border-b` |

## shadcn/Basecoat Components

Reference by exact component name:

| Instead of | Say |
|---|---|
| "button" | `<Button variant="default|destructive|outline|secondary|ghost|link" size="sm|default|lg|icon">` |
| "input field" | `<Input type="text|email|password" />` |
| "dropdown" | `<Select>` + `<SelectTrigger>` + `<SelectContent>` + `<SelectItem>` |
| "modal" | `<Dialog>` + `<DialogTrigger>` + `<DialogContent>` + `<DialogHeader>` + `<DialogFooter>` |
| "side panel" | `<Sheet side="left|right|top|bottom">` |
| "card" | `<Card>` + `<CardHeader>` + `<CardTitle>` + `<CardDescription>` + `<CardContent>` + `<CardFooter>` |
| "tabs" | `<Tabs defaultValue="tab1">` + `<TabsList>` + `<TabsTrigger>` + `<TabsContent>` |
| "table" | `<Table>` + `<TableHeader>` + `<TableRow>` + `<TableHead>` + `<TableBody>` + `<TableCell>` |
| "toast" | `useToast()` → `toast({ title, description, variant })` |
| "tooltip" | `<Tooltip>` + `<TooltipTrigger>` + `<TooltipContent>` |
| "toggle group" | `<ToggleGroup type="single|multiple">` + `<ToggleGroupItem>` |
| "badge/tag" | `<Badge variant="default|secondary|destructive|outline">` |
| "separator" | `<Separator orientation="horizontal|vertical" />` |
| "skeleton loader" | `<Skeleton class="h-4 w-[250px]" />` |
| "accordion" | `<Accordion type="single|multiple" collapsible>` + `<AccordionItem>` + `<AccordionTrigger>` + `<AccordionContent>` |
| "command palette" | `<Command>` + `<CommandInput>` + `<CommandList>` + `<CommandGroup>` + `<CommandItem>` |

## Message Format to Frontend

```
COMPONENTE: <ComponentName> en <path/exacto>
LAYOUT: [Tailwind utilities exactas, responsive breakpoints]
ESTADO: [refs, computeds, props con tipos TypeScript]
DATOS: [GraphQL query/mutation name, types del backend]
INTERACCIÓN: [eventos, emits, watchers]
DEPENDENCIAS: [composables, stores, imports necesarios]
CRITERIOS: [qué debe pasar para considerar completado]
```

## Examples

### Bad (descriptive)
"Crea una vista para ver los detalles de un vehículo. Debe mostrar la foto del carro, su información principal, y un botón para reservar. Que se vea bien en móvil."

### Good (technical)
```
COMPONENTE: CarDetailView en views/cars/CarDetailView.vue
LAYOUT: Container max-w-4xl mx-auto p-4. Grid grid-cols-1 md:grid-cols-2 gap-6.
  - Col 1: <img> con aspect-video rounded-lg object-cover, src desde car.primaryImage
  - Col 2: <Card> con <CardHeader> (car.brand + car.model as <CardTitle>),
    <CardContent> (specs en grid grid-cols-2 gap-2 text-sm text-muted-foreground),
    <CardFooter> (<Button size="lg" class="w-full"> "Reservar")
ESTADO: const car = ref<Car | null>(null). useRoute() para params.id.
  useCar(id) composable que ejecuta GET_CAR query.
DATOS: query GetCar($id: ID!) del schema GraphQL. Type Car de @/shared/types/car.ts
INTERACCIÓN: @click en Button → router.push({ name: 'booking-create', params: { carId } })
DEPENDENCIAS: useCar composable, useRoute, useRouter, Car type, Button, Card components
CRITERIOS: Mobile-first. Skeleton mientras carga. Error state si car no existe (404).
```

## Stack Reference

- Framework: Vue 3 (Composition API, `<script setup lang="ts">`)
- Styles: Tailwind CSS (OKLCH colors, responsive prefixes)
- Components: shadcn-vue / Basecoat
- State: Pinia stores (`defineStore`)
- API: GraphQL via `useGraphQL` composable, fetch nativo
- Types: TypeScript strict mode
- Router: vue-router 4
- i18n: vue-i18n (mensajes en `core/i18n/`)
- Icons: Lucide Vue
