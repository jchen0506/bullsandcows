#include<iostream>
#include<string>
#include<assert.h>
using namespace std;
string word[500];     //  global variebles, a char pointer array to store 100 words
bool isUniqueChar(const char * s) 
{
	assert(s != NULL);
	bool *a = new bool[256];     // for ascii code ,there are 256 possibilities ,each store the hash value of key
	memset(a, false, 256);    //initialize the bool array
	while (*s != '\0')
	{
		if (a[int(*(s))])
			return false;
		else
			a[int(*(s++))] = true;
	}
	if (*s == '\0')
		return true;
	return false;
}
int getsecret()         //2.	Pick up a random word from word bank (generating word bank with high level language.) 
{
	FILE *bank;
	bank = fopen("D:\\utd\\course syllabus\\3340 cs2\\group project\\resource.txt", "r");
	int i = 0;
	while (!feof(bank))      // read until the end of file
	{
		char tmp[20];      // temporary char for storing  each read operation
		fscanf(bank, "%s", tmp);
		string temp = tmp;
		//if (temp.length() == 4)      // only store 4-letter word
		//{
			if (isUniqueChar(tmp))        //test if the word is formed by unique letters
			{
				word[i] = temp;             //store it
				cout << word[i] << " ";    //  test
				i++; 
			}
		//}
	}
	fclose(bank);
	return i;      // return how many words created by the input file
}

string getHint(string secret, string guess) {              //
		int m[256] = { 0 }, bulls = 0, cows = 0;
		for (int i = 0; i < secret.size(); ++i) {          //if  secret.size()!=guess.size() , exe break down! so further prevention is needed!!!
			if (secret[i] == guess[i]) ++bulls;
			else ++m[secret[i]];
		}
		for (int i = 0; i < secret.size(); ++i) {
			if (secret[i] != guess[i] && m[guess[i]]) {
				++cows;
				--m[guess[i]];
			}
		}
		return to_string(bulls) + "A" + to_string(cows) + "B";         
	}
int main()             //   1.	Prompt option for user to choose(menu error ¨C entering numbers other than we give)
{
	string secret, guess;
	int word_num = getsecret();
	int i = rand() % word_num;
	secret = word[i];
	cout << word_num << endl;

	while (1)
	{
		cin>> guess;
		string result=getHint(secret, guess);
		cout << result << endl;
		if (result == "4A0B")
		{
			cout << "you get it!" << endl;
			break;
		}

	}
	return 0;
}
