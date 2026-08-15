# Get FedExCup / playoff bubble

Cutoff lines and nearby players for the current playoff or tour-card
bubble, when the API is publishing one for this tournament.

## Usage

``` r
pga_bubble(tournament_id, tour = "R")
```

## Arguments

- tournament_id:

  Character. Tournament ID.

- tour:

  Character. Tour code. Defaults to `"R"`.

## Value

A tibble of ranking rows around the cutoff.
