
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lyriclensR

<!-- badges: start -->

<!-- badges: end -->

The goal of lyriclensR is to test how to work with song lyrics. This is
a very experimental package. Most things should not work. Use at your
own risk.

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
| 4636662 | \<a href=‘<https://genius.com/Ye-vagabonds-i-courted-a-wee-girl-lyrics>’, target = ’\_blank’\>Ye Vagabonds<BR><BR>I Courted A Wee Girl<BR><BR>(?)</a> | The bride went in foremost she bore the best show<br>And I followed after my heart full of woe<br>To see my <a style = "color:red">LOVE</a> wed to another<br>Another<br>To see my <a style = "color:red">LOVE</a> wed to another<br><br>Well the bride and bride’s party in church they did stand<br>Gold rings on her fingers her <a style = "color:red">LOVE</a> by the hand<br>And the man she was wed to had houses and land<br>He may have her since I could not gain her<br>The more I looked on her she dazzled my sight<br>I lifted my hat and I bade her goodnight<br>Adieu to all false-hearted <a style = "color:red">LOVE</a>rs<br><a style = "color:red">LOVE</a>rs<br>Adieu to all false-hearted <a style = "color:red">LOVE</a>rs<br><br><br>And the next time I saw her she was living down neat<br>I sat down beside her not a bite could I eat<br>For I thought my <a style = "color:red">LOVE</a>’s company far better than meat<br>For <a style = "color:red">LOVE</a> was the cause of my ruin<br>My ruin<br>For <a style = "color:red">LOVE</a> was the cause of my ruin<br><br>So it’s dig me a grave and dig it down deep<br>And strew it all over with the roses so sweet<br>And lay me down silent no more for to weep<br>For <a style = "color:red">LOVE</a> was the cause of my ruin<br>My ruin<br>For <a style = "color:red">LOVE</a> was the cause of my ruin |

Create a wordcloud using the lyrics of an artist:

``` r
library(lyriclensR)
create_wordcloud(lyrics = filename)
```

![](man/figures/wordcloud.png)
