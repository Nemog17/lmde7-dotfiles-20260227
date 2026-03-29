import * as fs from 'fs/promises';
import * as path from 'path';
import { parse as parseYaml } from 'yaml';
import { LeadConfigSchema, type LeadConfig } from './types.js';

const LEAD_DIR = '.lead';
const CONFIG_FILE = 'config.yaml';

export async function loadConfig(workDir: string): Promise<LeadConfig | null> {
  const configPath = path.join(workDir, LEAD_DIR, CONFIG_FILE);
  try {
    const data = await fs.readFile(configPath, 'utf-8');
    const parsed = parseYaml(data);
    return LeadConfigSchema.parse(parsed);
  } catch {
    return null;
  }
}

export async function loadRules(workDir: string): Promise<string[]> {
  const config = await loadConfig(workDir);
  return config?.rules ?? [];
}

export async function loadBoundaries(workDir: string): Promise<string[]> {
  const config = await loadConfig(workDir);
  const userBoundaries = config?.boundaries?.never_touch ?? [];
  return [
    ...userBoundaries,
    '.lead/progress.txt',
    '.lead/deferred.json',
    '.lead-worktrees',
    '.lead-sandboxes',
  ];
}

export { type LeadConfig } from './types.js';
