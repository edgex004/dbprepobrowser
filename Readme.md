### Dependencies

- python3
- qt 5.15
- PySide2
- pydbus
- python-apt

### Modifying resources

Resources are entered into style.qrc. Modifying resources requires a recompilation of this file using `rcc` (which is located in the install folder of PySide2 for recent versions):

```rcc -g python ./style.qrc  > style_rc.py```

### Launching

Launch with:

```python3 ./main.py```