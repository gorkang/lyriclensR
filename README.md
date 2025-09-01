
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lyriclensR

<!-- badges: start -->

<!-- badges: end -->

The goal of lyriclensR is to test how to work with lyrics

## Installation

You can install the development version of lyriclensR with:

``` r
pak::pak("gorkang/lyriclensR")
```

For the Python dependencies:

``` r
reticulate::py_install("lyricsgenius", method = "virtualenv")
reticulate::py_install("undetected_chromedriver", method = "virtualenv")
reticulate::py_install("setuptools", method = "virtualenv") # setuptools includes distutils
```

## Example

This is a basic example which shows you how to download all the lyrics
for specific artists using the Genius API (maximum of 5000 calls for
each account per day. For more information
<https://developer.subscriptiongenius.com/2/intro/>):

``` r
download_all_artists("Ye Vagabonds")
```

A more complex example where we download and process all the lyrics for
the artists of a Spotify list:

``` r
library(lyriclensR)

download_process_spotify_list(
  spotify_list_URL = "https://open.spotify.com/playlist/3hdkI3sIYMAPTz2aXNgXt4",
  only_new = FALSE,
  continue_after_error = FALSE,
  end_message = TRUE)
```

Search for a word in the lyrics

``` r
# We include a lyrics file with the package
filename = system.file("extdata", package = "lyriclensR") |> list.files(full.names = TRUE)

OUTPUT = lyriclensR::search_words(data = filename, 
                         highlight_words = "love")

# Here we show only 2 results
knitr::kable(OUTPUT$DF_table |> dplyr::slice_sample(n = 2))
```

| id | Song | Lyrics |
|---:|:---|:---|
| 6433964 | \<a href=‘<https://genius.com/Ye-vagabonds-im-a-rover-lyrics>’, target = ’\_blank’\>Ye Vagabonds<BR><BR>I’m a Rover<BR><BR>(2021)</a> | This morning’s tempest I have to cross<br>I well be guided without a stumble<br>Into the arms that I <a style = "color:red">LOVE</a> the most<br><br>I’m a rover, seldom sober<br>I’m a rover of high degree<br>It’s when I’m drinking, I’m always thinking<br>How to gain my <a style = "color:red">LOVE</a>’s company<br><br>At last he came to his true <a style = "color:red">LOVE</a>’s dwelling<br>He sat on down there upon a stone<br>And through her window he whispered softly<br>“Is my true <a style = "color:red">LOVE</a>r within at home?”<br><br>I’m a rover, seldom sober<br>I’m a rover of high degree<br>It’s when I’m drinking, I’m always thinking<br>How to gain my <a style = "color:red">LOVE</a>’s company<br><br>She raised hеr head then fell off hеr pillow<br>I’m a rover of high degree<br>It’s when I’m drinking, I’m always thinking<br>How to gain my <a style = "color:red">LOVE</a>’s company<br><br><br>Get up, get up, now, it’s your true <a style = "color:red">LOVE</a>r<br>Get up, get up, now and let me in<br>For I am weary of my long journey<br>I’m a rover of high degree<br>It’s when I’m drinking, I’m always thinking<br>How to gain my <a style = "color:red">LOVE</a>’s company<br><br>She raised her head then fell off her pillow<br>I’m a rover of high degree<br>It’s when I’m drinking, I’m always thinking<br>How to gain my <a style = "color:red">LOVE</a>’s company<br>I’m a rover, seldom sober<br>I’m a rover of high degree<br>It’s when I’m drinking, I’m always thinking<br>How to gain my <a style = "color:red">LOVE</a>’s company<br>I’m a rover, seldom sober<br>I’m a rover of high degree<br>It’s when I’m drinking, I’m always thinking<br>How to gain my <a style = "color:red">LOVE</a>’s company |
| 4989925 | \<a href=‘<https://genius.com/Ye-vagabonds-lowlands-of-holland-lyrics>’, target = ’\_blank’\>Ye Vagabonds<BR><BR>Lowlands of Holland<BR><BR>(2017)</a> | The <a style = "color:red">LOVE</a> that I have chosen, I’ll therewith be content<br>The salt sea shall be frozen, before that I repent<br>Repent it shall I never, until the day I die<br>For the Lowlands of Holland have twined my <a style = "color:red">LOVE</a> and I<br><br>\[Verse 2\]<br>My <a style = "color:red">LOVE</a> lies in the salt sea, and I am on the side<br>Enough to break a young thing’s heart, what lately was a bride<br>What lately was a bonny bride, and pleasure in her eye<br>For the Lowlands of Holland have twined my <a style = "color:red">LOVE</a> and I<br><br>\[Verse 3\]<br>My <a style = "color:red">LOVE</a> he built a bonny ship and set her on the sea<br>With seven score good mariners for to bear her company<br>But the weary winds began to rise, the sea began to rout<br>And my <a style = "color:red">LOVE</a> then and his bonny ship turned withershins about<br><br>\[Verse 4\]<br>There shall neither coif come on my head, nor comb come through my hair<br>There shall neither coal nor candle-light shine in my bower mair<br>Nor will I <a style = "color:red">LOVE</a> another one, until the day I die<br>For the high winds and stormy seas have twined my <a style = "color:red">LOVE</a> and I<br><br>\[Verse 5\]<br>There are mair lads in Galloway, ye need na sair lament<br>Oh there is nane in Galloway, there’s nane at a’ for me<br>For I never <a style = "color:red">LOVE</a>d a <a style = "color:red">LOVE</a> but one, and he’s drowned in the sea |

Create a wordcloud using the lyrics of an artist:

``` r
library(lyriclensR)
create_wordcloud(lyrics = filename)
```

![](man/figures/wordcloud.png)
