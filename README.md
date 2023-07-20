![](https://github.com/senselogic/BAX/blob/master/LOGO/bax.png)

# Bax

Basil data fixer.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 bax.d
```

## Command line

```
bax <file filter>
```

### Example

```bash
bax ".//*.bd"
```

Fix the Basil data files of the current folder and its subfolders.

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
