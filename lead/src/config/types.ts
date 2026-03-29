import { z } from 'zod';

export const TeammateConfigSchema = z.object({
  description: z.string(),
  model: z.string().default('sonnet'),
  engine: z.enum(['claude-cli', 'codex', 'gemini']).default('claude-cli'),
  agent_definition: z.string().optional(),
  agent_type: z.string().optional(),
  mode: z.string().optional(),
});

export const ClassifierConfigSchema = z.object({
  engine: z.string().default('claude-cli'),
  model: z.string().default('haiku'),
});

export const LeadConfigSchema = z.object({
  project: z.object({
    name: z.string(),
    language: z.string().optional(),
    framework: z.string().optional(),
    description: z.string().optional(),
  }),
  team: z.record(z.string(), TeammateConfigSchema).default({}),
  classifier: ClassifierConfigSchema.optional(),
  commands: z.object({
    test: z.string().optional(),
    lint: z.string().optional(),
    build: z.string().optional(),
  }).optional(),
  rules: z.array(z.string()).default([]),
  boundaries: z.object({
    never_touch: z.array(z.string()).default([]),
  }).optional(),
});

export type LeadConfig = z.infer<typeof LeadConfigSchema>;
export type TeammateConfig = z.infer<typeof TeammateConfigSchema>;
