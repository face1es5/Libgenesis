# Introduction
MacOS client for library gensis.  
Pure swift implementation.  
Enjoy the smooth experience of Aqua.  
**Inform: Download needs access to ~/Downloads folder.(But you can change default location in settings)**

# So, what can this app do?

1. Display available books on libgen.  
2. Search books from libgen, currently support column filter and formart filters.  
3. Obviously, download.  
4. That's it, maybe suport more features in future(.e.g, directly preview before download?)

# Usage

## Main window

![main-screenshot](./Resources/main.png)

## Books list

As you see, once startup this app or search sth, a list of books will be displayed, you can choose 2 display mode:

1. Cover mode:

   ![covermode](./Resources/covermode.jpg)

2. List mode:

   ![listmode](./Resources/listmode.jpg)

**When you scroll to bottom, you can click more to query books of next page.**

## Details

When you select a book from list, you can see its details info in left panel, like this:

![details](./Resources/details.jpg)

On top is three mode to display details panel: complex/common/simple, choose what you like.

## Download

Select one book or multi books, and select download these books in context menu:

![download-context](./Resources/download1.jpg)

You can see these downloads by press download button in toolbar:

![downloader](./Resources/download2.jpg)

In fact you can redownload in context menus if download process failed:

![download3](./Resources/download3.jpg)

You can pause and resume too:

![download4](./Resources/download4.jpg)

At this point, resume just redownload entire file, maybe support real resume in future.

## Search

By default if you don't set filters, it will search all columns and return books that contains the search string, for example:

Here we search for 'hello':

![search-1](./Resources/search1.jpg)

And if we want to search someone's books, .e.g David, we could set column filters to Author and type David in search bar:

![search-2](./Resources/search2.jpg)

What if we want to search Bender's all books that format is djvu? Just set the format filter too:

![search-3](./Resources/search3.jpg)

Also, you can select multi formats, so you can search Bender's both djvu and pdf books:

![serch-4](./Resources/search4.jpg)

Maybe you have noticed there's a weird num sequences, in fact this is used for decided how much books is quried and returned, as you see, there is 25, 50, and 100, **don't recommend to set this to 100, although it supports, you could be blocked as you send too much requests to libgen.**

## Bookmarks

By click following menu, you can add(or remove it if it already is) bookmarks persistently:

![b1](./Resources/bookmark1.jpg)

![b2](./Resources/bookmark2.jpg)

You can see bookmarks by click this button:

![b3](./Resources/bookmark3.jpg)

## 

