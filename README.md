
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
| 7953258 | 7953258<BR><BR>\<a href=‘<https://genius.com/Ye-vagabonds-her-mantle-so-green-lyrics>’, target = ’\_blank’\>Ye Vagabonds<BR><BR>Her Mantle So Green<BR><BR>(2022)</a> | For I’ll wed with no man, you must be refused;<br>To the green woods I will wander to shun all men’s view<br>For the boy I <a style = "color:red">LOVE</a> dearly fell in famed Waterloo<br><br>\[Verse 5\]<br>And since you will not marry me, will you tell me your <a style = "color:red">LOVE</a>’s name<br>As I fought in that battle, I might know the same<br>Draw near to my garment, for there can be seen<br>\[Verse 7\]<br>We fought there together where the bullets did fly<br>On the field of battle your true <a style = "color:red">LOVE</a> does lie<br>We fought for three days till the fourth afternoon<br>He received his death summons on the eighteenth of June<br>\[Verse 8\]<br>And as he lay dying, these words he did say<br>“If you were here <a style = "color:red">LOVE</a>ly Nancy how contented I’d die”<br>When she heard this sad tale, then her tears they did flow<br>She fell into my arms with a heart full of woe<br><br>\[Verse 9\]<br>Oh Nancy, <a style = "color:red">LOVE</a>ly Nancy, it was I won your heart<br>In your father’s garden, the day we did part<br>In your father’s garden, the truth I declare<br>Here is our <a style = "color:red">LOVE</a> token, this gold ring I wear<br><br>\[Verse 10\]<br>And if you’ll still have me, one word to me say<br>And we’ll feast with great nobles on our wedding day<br>For peace is proclaimed <a style = "color:red">LOVE</a>, the war it is won<br>You’re welcome to my arms, <a style = "color:red">LOVE</a>ly Nancy once more |
| 5769307 | 5769307<BR><BR>\<a href=‘<https://genius.com/Ye-vagabonds-border-widows-lament-lyrics>’, target = ’\_blank’\>Ye Vagabonds<BR><BR>Border Widow’s Lament<BR><BR>(2015)</a> | My <a style = "color:red">LOVE</a>, he built me a bonny bower<br>And clad it o’er with lily flower<br>A finer bower you ne’er did see<br>Than my true <a style = "color:red">LOVE</a> he built for me<br><br>\[Verse 2\]<br><br>\[Verse 7\]<br>No living man I’ll <a style = "color:red">LOVE</a> again<br>Since that my <a style = "color:red">LOVE</a>ly knight is slain<br>And with a lock of his yellow hair<br>I’ll chain my heart forevermore |

Create a wordcloud using the lyrics of an artist:

``` r
library(lyriclensR)
create_wordcloud(lyrics = filename)
```

![](man/figures/wordcloud.png)
