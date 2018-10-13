# Standardize list items after raising each item to power
def standardizeList(number_list, power):
    newList = []
    sumList = 0
    for number in number_list:
        sumList += number**power
    for number in number_list:
        newList.append((number**power) / sumList)
    return(newList)