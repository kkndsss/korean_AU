from huggingface_hub import create_repo, upload_folder

#본인 레포 만들고 시작해야함.
create_repo("yongjinsesac/base-bert-model", exist_ok=True)


#실제 올리려고 하는 학습 모델이 담긴 체크포인트(토크나이저 모두 포함) 디렉토리를 지정해야함. 토크나이저 없으면 다음번에 못 불러옴.
upload_folder(folder_path="/home/kkndsss1/korean_AU/model/results/checkpoint-1200", path_in_repo="checkpoints/checkpoint-1200", repo_id="yongjinsesac/base-bert-model", token=True)
print("done")

#실행 : korean_AU에서 python src/hug_model.up.py