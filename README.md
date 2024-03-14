![GitHub release (latest by date)](https://img.shields.io/github/v/release/zerothi/ts-tbt-sisl-tutorial?label=tutorial)
[![Join discussion on Discord](https://img.shields.io/discord/742636379871379577.svg?label=&logo=discord&logoColor=ffffff&color=green&labelColor=red)](https://discord.gg/bvJ9Zuk)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/zerothi/ts-tbt-sisl-tutorial/2023?filepath=tutorial.ipynb)
[![License](https://mirrors.creativecommons.org/presskit/buttons/88x31/svg/by-sa.svg)](http://creativecommons.org/licenses/by-sa/4.0/)

Welcome to sisl + TBtrans + TranSiesta tutorial
===============================================

This is the tutorial used for sisl + TBtrans + TranSiesta workshops.

The sources used for these tutorials can be found elsewhere:


- [sisl][sisl@git] (>= 0.14.3)
- [TBtrans][tbtrans] (>= 4.1.5)
- [Siesta][tbtrans] (>= 4.1.5)


If you have installed using the installation script you will have access
to MPI parallelized executables.


Binder
------

This tutorial may be runned using [Binder](https://mybinder.readthedocs.io/en/latest/).
Note that we highly recommend using a local Conda installation since that is much
more versatile and since this tutorial requires lots of text-editing which is hard
to do in a Jupyter notebook.

However, if you want to play around you may do so, for a good experience you are
recommended to execute tbtrans like this:

    !OMP_NUM_THREADS=1 tbtrans RUN.fdf

since the installed `tbtrans` is threaded and binder is sharing resources.

License
-------

sisl © 2020 by Nick Papior is licensed under CC BY-SA 4.0. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/


<!---
Links to external and internal sites.
-->
[sisl@git]: https://github.com/zerothi/sisl
[tbtrans]: https://gitlab.com/siesta-project/siesta
