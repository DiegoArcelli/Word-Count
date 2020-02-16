# Word-Count
An implementation of the word count bash command in x86-64 Assembly language.<br>
Like any bash command the parameters of the program are passed as command line arguments in the following way:<br><br>
./wc [OPTION]... [FILE]<br><br>
The possible options are these:
- -l: to return the numbers of lines inside the file
- -w: to return the numbers of words inside the file
- -m: to return the number of characters inside the file

The last argument is always the file name. If there is no options inserted then the program will automatically add all three of them.<br>
The program doesn't check if the arguments are passed correctly, so I don't guarantee anything about the program bheaviour in that case.
