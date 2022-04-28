string = str(input())
file_string = "M:/Senior Design/quartus_project/quartus_project_revert_5s_blink/quartus_project_revert_5s_blink/quartus_project_revert_5s_blink/" + string
read_file = open(file_string, "r")
contents = read_file.read()
d = contents.split()

range = {0, 1, 2, 3}
for i in range:
  namestring = string
  path = "M:/Senior Design/quartus_project/quartus_project_revert_5s_blink/quartus_project_revert_5s_blink/quartus_project_revert_5s_blink/" + str(i) +namestring
  f = open(path, "w")
  index = 0
  for word in d :
      if word[0] == "@":
          f.write(word + "\n")
      else:
        f.write(word[7 - (i * 2) - 1] + word[7 - (i * 2)] + "\n")
