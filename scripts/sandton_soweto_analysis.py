#!/usr/bin/env python3
"""Reproducible analysis for Linguistic Capital or Linguistic Barrier?

Input: interview_dataset_sandton_soweto.csv (60 participant-level records).
Run: python sandton_soweto_analysis.py [--data PATH] [--outdir PATH]

The dataset contains one final label per participant, not independent ratings
from multiple coders. Accordingly, Cohen's kappa is only demonstrated as a
self-agreement validation (kappa=1) and a shuffled-label permutation baseline;
it is not presented as inter-rater reliability.
"""
from __future__ import annotations
import argparse
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import chi2_contingency

LOCATIONS = ['Sandton', 'Soweto']
LABELS = ['Standard', 'Inclusion', 'Neutral']
PALETTE = {'Standard':'#355C7D', 'Inclusion':'#2A9D8F', 'Neutral':'#E9C46A'}


def load_data(path: Path) -> pd.DataFrame:
    data = pd.read_csv(path)
    required = {'Participant ID', 'Raw Response Extract', 'Code', 'Category', 'Final Label'}
    missing = required.difference(data.columns)
    if missing:
        raise ValueError(f'Missing required columns: {sorted(missing)}')
    data = data.copy()
    data['Location'] = np.where(data['Participant ID'].astype(str).str.startswith('SW-'), 'Soweto', 'Sandton')
    data['Final Label'] = data['Final Label'].astype(str).str.strip()
    if data['Participant ID'].duplicated().any():
        raise ValueError('Participant IDs must be unique for this analysis.')
    if set(data['Location']) != set(LOCATIONS):
        raise ValueError(f'Expected Sandton and Soweto, found {sorted(data["Location"].unique())}')
    if set(data['Final Label']) != set(LABELS):
        raise ValueError(f'Unexpected final labels: {sorted(data["Final Label"].unique())}')
    return data


def kappa(y1, y2):
    """Unweighted Cohen kappa for two categorical vectors."""
    a, b = np.asarray(y1), np.asarray(y2)
    if len(a) != len(b) or not len(a):
        raise ValueError('Ratings must have equal, nonzero length.')
    po = np.mean(a == b)
    cats = np.union1d(a, b)
    pe = sum(np.mean(a == c) * np.mean(b == c) for c in cats)
    return 1.0 if np.isclose(pe, 1.0) and np.isclose(po, 1.0) else (po-pe)/(1-pe)


def diversity_metrics(counts):
    p = np.asarray(counts, dtype=float)
    p = p[p > 0] / p.sum()
    return {'shannon_nats': float(-np.sum(p*np.log(p))),
            'shannon_bits': float(-np.sum(p*np.log2(p))),
            'simpson_diversity': float(1-np.sum(p*p)),
            'simpson_concentration': float(np.sum(p*p))}


def make_figures(data, table, outdir):
    sns.set_theme(style='whitegrid', context='paper', font_scale=1.15)
    plt.rcParams.update({'font.family':'DejaVu Sans','axes.spines.top':False,
                         'axes.spines.right':False,'savefig.dpi':350,
                         'figure.facecolor':'white'})
    # Figure 1: Ideological distribution
    fig, ax = plt.subplots(figsize=(7.2, 4.8))
    long = table.rename_axis('Location').reset_index().melt(id_vars='Location', var_name='Final label', value_name='Participants')
    sns.barplot(data=long, x='Location', y='Participants', hue='Final label',
                hue_order=LABELS, palette=PALETTE, ax=ax, edgecolor='white', linewidth=.8)
    ax.set(title='Figure 1. Ideological distribution by study site', xlabel='', ylabel='Participants (n)')
    ax.legend(title='Final label', frameon=False, ncol=3, loc='upper center', bbox_to_anchor=(.5,1.0))
    for c in ax.containers: ax.bar_label(c, fmt='%d', padding=2, fontsize=9)
    fig.tight_layout(); fig.savefig(outdir/'figure1_ideological_distribution.png', bbox_inches='tight'); fig.savefig(outdir/'figure1_ideological_distribution.pdf', bbox_inches='tight'); plt.close(fig)
    # Figure 2: thematic dimensions, actual dataset categories cross-tabulated by site
    themes = pd.crosstab(data['Location'], data['Category']).reindex(index=LOCATIONS, fill_value=0)
    themes = themes.reindex(columns=sorted(themes.columns), fill_value=0)
    fig, ax = plt.subplots(figsize=(8.2, 4.8))
    themed = themes.rename_axis('Location').reset_index().melt(id_vars='Location', var_name='Thematic dimension', value_name='Participants')
    sns.barplot(data=themed, x='Thematic dimension', y='Participants', hue='Location',
                palette={'Sandton':'#355C7D','Soweto':'#D1495B'}, ax=ax, edgecolor='white')
    ax.set(title='Figure 2. Thematic dimensions by study site', xlabel='', ylabel='Participants (n)')
    ax.tick_params(axis='x', rotation=15); ax.legend(title='', frameon=False)
    for c in ax.containers: ax.bar_label(c, fmt='%d', padding=2, fontsize=8)
    fig.tight_layout(); fig.savefig(outdir/'figure2_thematic_dimensions.png', bbox_inches='tight'); fig.savefig(outdir/'figure2_thematic_dimensions.pdf', bbox_inches='tight'); plt.close(fig)
    # Figure 3: conceptual schematic: explanatory framing, not fitted causal model
    fig, ax = plt.subplots(figsize=(9.2, 4.6)); ax.set_xlim(0, 10); ax.set_ylim(0, 5); ax.axis('off')
    boxes=[(0.3,1.7,2.5,1.5,'Socio-economic\ncontext\nSandton / Soweto','#E7EEF5'),
           (3.75,1.7,2.5,1.5,'Accent, identity &\nlinguistic resources','#E5F3F0'),
           (7.2,1.7,2.5,1.5,'Ideological positioning\nStandard / Inclusion / Neutral','#FFF1D6')]
    for x,y,w,h,label,color in boxes:
        ax.add_patch(plt.Rectangle((x,y),w,h,facecolor=color,edgecolor='#34495E',linewidth=1.5,joinstyle='round'))
        ax.text(x+w/2,y+h/2,label,ha='center',va='center',fontsize=11,weight='medium')
    ax.annotate('',xy=(3.65,2.45),xytext=(2.9,2.45),arrowprops=dict(arrowstyle='->',lw=1.8,color='#34495E'))
    ax.annotate('',xy=(7.1,2.45),xytext=(6.35,2.45),arrowprops=dict(arrowstyle='->',lw=1.8,color='#34495E'))
    ax.text(5,4.25,'Figure 3. Conceptual framework for comparative interpretation',ha='center',fontsize=13,weight='bold')
    ax.text(5,.75,'Interpretive framework; arrows do not imply causal identification.',ha='center',fontsize=9,color='#555555')
    fig.tight_layout(); fig.savefig(outdir/'figure3_theoretical_framework.png', bbox_inches='tight'); fig.savefig(outdir/'figure3_theoretical_framework.pdf', bbox_inches='tight'); plt.close(fig)


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--data', type=Path, default=Path(__file__).with_name('interview_dataset_sandton_soweto.csv'))
    parser.add_argument('--outdir', type=Path, default=Path(__file__).with_name('analysis_outputs'))
    args=parser.parse_args(); args.outdir.mkdir(parents=True, exist_ok=True)
    data=load_data(args.data)
    table=pd.crosstab(data['Location'],data['Final Label']).reindex(index=LOCATIONS,columns=LABELS,fill_value=0)
    if len(data)!=60 or not np.array_equal(table.to_numpy(),np.array([[24,3,3],[0,30,0]])):
        raise ValueError(f'Data do not reproduce the expected 60-record table:\n{table}')
    chi2,p,dof,expected=chi2_contingency(table, correction=False)
    n=table.to_numpy().sum(); v=float(np.sqrt(chi2/(n*min(table.shape[0]-1,table.shape[1]-1))))
    print('Contingency table (rows: location; columns: Standard, Inclusion, Neutral)')
    print(table.to_string()); print(f'Pearson chi-square={chi2:.3f}, df={dof}, p={p:.12g}, Cramers V={v:.3f}')
    print('Expected counts:\n',pd.DataFrame(expected,index=LOCATIONS,columns=LABELS).to_string())
    for loc in LOCATIONS: print(f'{loc} diversity: {diversity_metrics(table.loc[loc].values)}')
    # Kappa demonstration, not inter-rater evidence
    labels=data['Final Label'].to_numpy()
    print(f'Kappa validation (labels against themselves; not inter-rater): {kappa(labels,labels):.3f}')
    rng=np.random.default_rng(20250308)
    sims=np.array([kappa(labels,rng.permutation(labels)) for _ in range(2000)])
    print(f'Permutation baseline (n=2000, seed=20250308): mean kappa={sims.mean():.3f}; 2.5-97.5% [{np.quantile(sims,.025):.3f}, {np.quantile(sims,.975):.3f}]')
    print('Caution: 4/6 Pearson expected cells are <5; interpret asymptotic p cautiously. Fisher-Freeman-Halton exact test can be run in R.')
    make_figures(data,table,args.outdir); print(f'Figures saved to {args.outdir.resolve()}')

if __name__=='__main__': main()
