Pandemic Responses
```ruby
POST '/action' {
    action: {
        type: 'move',
        metadata: {
            city: 'city_name'
        }
    }
}

{
    action: {
        type: 'treat'
    }
}

{
    action: {
        type: 'cure'
        metadata: {
            cards: ['card_id_1', 'card_id_2', '...']
        }
    }
}

GET '/state' {
    board: {
        cities: {
            city_id_1: {
                cube_count: 10,
                adjacent_cities: ['city_id1', '...']
            }
        },
        players: {
            player_id: {
                current_city: 'city_id',
                cards: ['card_id_1', '...']
            }
        },
        curent_turn: {
            player_id: 'player_id',
            actions_left: 10
        },
        player_cards_left: 10,
        infection_cards_left: 10,
        infection_rate: 2,
        outbreak_count: 0
        discarded_player_cards: ['player_card_id', '...'],
        discarded_infection_cards: ['infection_card_id', '...']
    }
}
```
