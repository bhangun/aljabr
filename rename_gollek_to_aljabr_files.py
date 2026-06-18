import os

aljabr_dir = "/Users/bhangun/Workspace/workkayys/Products/Wayang/wayang-platform/aljabr"

for root, dirs, files in os.walk(aljabr_dir):
    for file in files:
        if file.startswith("Gollek") and file.endswith(".java"):
            file_path = os.path.join(root, file)
            new_file_name = file.replace("Gollek", "Aljabr", 1)
            new_file_path = os.path.join(root, new_file_name)
            
            print(f"Renaming {file_path} -> {new_file_path}")
            os.rename(file_path, new_file_path)
