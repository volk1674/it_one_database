from collections import defaultdict

import pprint
import requests

pp = pprint.PrettyPrinter(indent=2)

page = 1
total = 0

counter = defaultdict(int)
game_counter = defaultdict(int)
max_score = 0
max_score_result = None

while True:
    resp = requests.get(f"https://cups.online/api_v2/battles/task/1528/?page={page}&page_size=108")
    data = resp.json()
    totals = data['totals']

    for result in data['results']:
        br = result['battle_results']
        total += 1
        game_counter[br[0]['user']['login']] += 1
        game_counter[br[1]['user']['login']] += 1

        if max_score < br[0]['score'] or max_score < br[1]['score']:
            max_score = max(br[0]['score'], br[1]['score'])
            max_score_result = result

        if br[0]['score'] > br[1]['score']:
            counter[br[0]['user']['login']] += 2
            counter[br[1]['user']['login']] += 0
        elif br[0]['score'] < br[1]['score']:
            counter[br[0]['user']['login']] += 0
            counter[br[1]['user']['login']] += 2
        else:
            counter[br[0]['user']['login']] += 1
            counter[br[1]['user']['login']] += 1

    if total >= totals:
        break

    page += 1


print("Игра с максимальным результатом:")
pp.pprint(max_score_result)
print("\n\n")

for rec in sorted(counter.items(), key=lambda elm: elm[1]/game_counter[elm[0]], reverse=True):
    print(f"{rec[0]}:\t{game_counter[rec[0]]}\t{rec[1]}\t{rec[1]/game_counter[rec[0]]}")
