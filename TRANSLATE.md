*Quick links :*
[Home](/README.md) - [Part 1](/en/part1/README.md) - [Part 2](/en/part2/README.md) - [Part 3](/en/part3/README.md) - [Part 4](/en/part4/README.md)
***

# Translating the ESP8266 IoT Workshop

We would welcome any offers to translate the workshop into other languages.  

Here are some pointer to be aware of before proceeding:

- The master branch is always the English content.  Translations should represent the content of the English version.
- If you want to change content whilst translating, don't.  Translate he current English content and raise a git issue requesting a content change to the English content then wait for the change to be delivered (or rejected).
- This is not a static repo, so as changes are made you should follow the repo and reflect changes to the English content in your translation.  We want translations to be kept in line with the English content, so you are not willing to make updates as needed, please don't offer to translate.
  
## How to translate

- Fork the workshop repository
- Follow the master repository (so you are notified of changes that may need your translation to be updated)
- Work locally in your forked version of the repository
- Copy the README.md file in the repo root directory and rename the copy to README.**lang**.md, where **lang** is replaced with the 2 letter (lower case) language code (e.g. fr-France, de-German...).  
- Translate the content of the README.**lang**.md page.  You should also add your language to the line of languages available:

```md
  Complete this workshop in another language: [English](/README.md), [Português](/README.pt.md)
```

- You should add your language to all the README files in the root directory.  The name of the language in square brackets [] should be in the translated language rather than English (E.g. Español rather than Spanish).

- Copy the entire content of the **en** directory into a new directory.  The new directory should be named the 2 lower case language code *(e.g. **pt** for Portuguese, **fr** for French, **de** for German ...)*
- When translating do not translate/change the names of files, as these are used for navigating between pages.
- You need to fix the home link at the top and bottom of every page you translate to point to your translated home page.  README.**lang**.md instead of README.md.  All other links within the content are relative, so should just work.
- Translate all the pages in your **lang** directory
- When you are happy that your translation is complete and works in your forked git repo.  Create a pull request in the master repo to deliver your translation live.

***
*Quick links :*
[Home](/README.md) - [Part 1](/en/part1/README.md) - [Part 2](/en/part2/README.md) - [Part 3](/en/part3/README.md) - [Part 4](/en/part4/README.md)
