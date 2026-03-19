import re

with open('coverage/lcov.info', 'r', encoding='utf-8') as f:
    content = f.read()

blocks = content.split('SF:')[1:]

line_results = []
branch_results = []
total_lines = 0
covered_lines = 0
total_branches = 0
covered_branches = 0

for block in blocks:
    lines = block.split('\n')
    sf = lines[0]
    
    covered = 0
    total = 0
    branches = {}
    
    for line in lines[1:]:
        if line.startswith('DA:'):
            parts = line[3:].split(',')
            total += 1
            if int(parts[1]) > 0:
                covered += 1
        elif line.startswith('BRDA:'):
            parts = line[4:].split(',')
            if len(parts) >= 4:
                line_num, block, branch, hit = parts[0], parts[1], parts[2], parts[3]
                key = f'{line_num}_{block}_{branch}'
                if key not in branches or int(hit) > branches[key]:
                    branches[key] = int(hit)
    
    total_lines += total
    covered_lines += covered
    pct = (covered / total * 100) if total > 0 else 0
    line_results.append((sf, covered, total, pct))
    
    for hit in branches.values():
        total_branches += 1
        if hit > 0:
            covered_branches += 1
    
    br_hit = len([h for h in branches.values() if h > 0])
    br_total = len(branches)
    br_pct = (br_hit / br_total * 100) if br_total > 0 else 0
    branch_results.append((sf, br_hit, br_total, br_pct))

line_results.sort(key=lambda x: x[3])
branch_results.sort(key=lambda x: x[3])

print('=' * 75)
print('LINE COVERAGE')
print('=' * 75)
print(f'{"File":<50} {"Covered":>8} {"Total":>6} {"%":>6}')
print('-' * 75)
for path, covered, total, pct in line_results:
    name = path.split('\\')[-1]
    status = 'OK' if pct >= 80 else ('WARN' if pct >= 50 else 'LOW')
    print(f'{name:<50} {covered:>8} {total:>6} {pct:>5.1f}% {status}')
print('=' * 75)
overall_line = (covered_lines / total_lines * 100) if total_lines > 0 else 0
print(f'{"TOTAL":<50} {covered_lines:>8} {total_lines:>6} {overall_line:>5.1f}%')

print()
print('=' * 75)
print('BRANCH COVERAGE')
print('=' * 75)
print(f'{"File":<50} {"Hit":>6} {"Total":>6} {"%":>6}')
print('-' * 75)
for path, hit, total, pct in branch_results:
    name = path.split('\\')[-1]
    status = 'OK' if pct >= 80 else ('WARN' if pct >= 50 else 'LOW')
    print(f'{name:<50} {hit:>6} {total:>6} {pct:>5.1f}% {status}')
print('=' * 75)
overall_branch = (covered_branches / total_branches * 100) if total_branches > 0 else 0
print(f'{"TOTAL":<50} {covered_branches:>6} {total_branches:>6} {overall_branch:>5.1f}%')
