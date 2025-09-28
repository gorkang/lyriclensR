
<!-- README.md is generated from README.Rmd. Please edit only README.Rmd -->

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

Will need a `.Renviron` variable called `GENIUS_TOKEN` with your Genius
API.

## Example

This is a basic example which shows you how to download all the lyrics
for specific artists using the Genius API (maximum of 5000 calls for
each account per day. Please, be gentle and avoid massive downloads. For
more information <https://developer.subscriptiongenius.com/2/intro/>):

``` r
download_all_artists("Ye Vagabonds")
```

Here we download and process the lyrics for the songs of a Spotify list:

``` r
library(lyriclensR)

MyList = get_and_process_spotify_list(spotify_list_URL = "https://open.spotify.com/playlist/3hdkI3sIYMAPTz2aXNgXt4")
download_individual_songs(MyList)
```

Search for a word in the lyrics

``` r
# We include a small lyrics file with the package (100 songs)
filename = system.file("extdata", package = "lyriclensR") |> list.files(full.names = TRUE)

OUTPUT = lyriclensR::search_words(lyrics = filename, 
                                  highlight_words = "love")

# Here we show only 2 results
knitr::kable(OUTPUT$DF_table |> dplyr::slice_sample(n = 2))
```

| id | Song | Lyrics |
|---:|:---|:---|
| 5769353 | 5769353<BR><BR>\<a href=‘<https://genius.com/Ye-vagabonds-barbara-ellen-lyrics>’, target = ’\_blank’\>Ye Vagabonds<BR><BR>Barbara Ellen<BR><BR>(2015)</a> | When the rose buds they were swellin’<br>Young William on his death bed lay<br>All for the <a style = "color:red">LOVE</a> of Barbry Ellen<br><br>\[Verse 2\]<br>They grew and grew up the churchyard wall<br>Till they could grow no higher<br>And they wound and bound in a true <a style = "color:red">LOVE</a>r’s knot<br>The red rose and the briar |
| 5044027 | 5044027<BR><BR>\<a href=‘<https://genius.com/Ye-vagabonds-go-where-you-will-lyrics>’, target = ’\_blank’\>Ye Vagabonds<BR><BR>Go Where You Will<BR><BR>(2017)</a> | Go, when I was knocked down<br>In the violence of the<br>Storm of a fleeting <a style = "color:red">LOVE</a><br><br>\[Chorus\]<br>Go where you will, go where you will<br>Go where you will<br><a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a><br><br>Go where you will, go where you will<br>Go where you will<br><a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a><br><br><br>To reflect the patterns<br>Of my predilection<br>For a repeating <a style = "color:red">LOVE</a><br><br>\[Chorus\]<br>Go where you will, go where you will<br>Go where you will<br><a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a><br><br>Go where you will, go where you will<br>Go where you will<br><a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a><br><br><br>Fade the hallows of the<br>Night will shade the spark of<br><a style = "color:red">LOVE</a> living and unplanned<br><br>\[Chorus\]<br>Go where you will, go where you will<br>Go where you will<br><a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a><br><br>Go where you will, go where you will<br>Go where you will<br><a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a> who you will <a style = "color:red">LOVE</a> |

Create a wordcloud using the lyrics of an artist:

``` r
library(lyriclensR)
create_wordcloud(lyrics = filename)
```

![](man/figures/wordcloud.png)
