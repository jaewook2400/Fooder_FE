//서버에 존재하는 레시피로, 사용자 정보와 관련이 없음. 로컬이든 뭐든 간에 모든 레시피는 모두 여기 있어야 하며, recipeId를 가져야 함.
final List<Map<String, dynamic>> recipes = [
  {
    "recipeId": 1,
    "name": "계란볶음밥",
    "timeToCook": 15,
    "ingredient": ["계란", "밥", "대파", "케첩"],
    "description": "계란을 이용한 밥 요리입니다.",
    "imageUrl": "http://fiscom/300/400",
    "process": [
      "프라이팬에 기름을 부어 달군다.",
      "계란과 밥, 대파를 넣어 볶는다.",
      "기호에 맞게 양념을 추가한다."
    ]
  },
  {
    "recipeId": 2,
    "name": "김치볶음밥",
    "timeToCook": 20,
    "ingredient": ["김치", "양파", "굴소스", "새송이버섯"],
    "description": "김치를 이용한 밥 요리입니다.",
    "imageUrl": "http://fiscom/300/401",
    "process": [
      "프라이팬에 기름을 두르고 김치를 볶는다.",
      "밥을 넣고 볶는다.",
      "간을 맞춘다."
    ]
  },
  {
    "recipeId": 3,
    "name": "파스타",
    "timeToCook": 25,
    "ingredient": ["스파게티면", "토마토 소스"],
    "description": "면과 소스로 만드는 요리입니다.",
    "imageUrl": "http://fiscom/300/402",
    "process": [
      "면을 삶는다.",
      "소스를 끓인다.",
      "면과 소스를 섞는다."
    ]
  },
  {
    "recipeId": 4,
    "name": "된장찌개",
    "timeToCook": 30,
    "ingredient": ["된장", "두부", "감자", "애호박", "대파"],
    "description": "된장과 채소를 넣어 끓이는 한국 전통 찌개입니다.",
    "imageUrl": "http://fiscom/300/403",
    "process": [
      "물에 된장을 풀고 끓인다.",
      "감자와 애호박을 넣어 익힌다.",
      "두부와 대파를 넣고 마무리한다."
    ]
  },
  {
    "recipeId": 5,
    "name": "불고기",
    "timeToCook": 35,
    "ingredient": ["소고기", "양파", "간장", "설탕", "참기름"],
    "description": "양념한 소고기를 볶아 만드는 대표적인 한국 요리입니다.",
    "imageUrl": "http://fiscom/300/404",
    "process": [
      "소고기를 양념에 재운다.",
      "야채와 함께 볶는다.",
      "익으면 접시에 담는다."
    ]
  },
  {
    "recipeId": 6,
    "name": "오므라이스",
    "timeToCook": 20,
    "ingredient": ["계란", "밥", "양파", "케첩", "당근"],
    "description": "볶음밥을 계란으로 감싸 만든 요리입니다.",
    "imageUrl": "http://fiscom/300/405",
    "process": [
      "야채와 밥을 볶아 케첩으로 간한다.",
      "계란을 부쳐 얇게 만든다.",
      "볶음밥을 올려 감싸준다."
    ]
  },
  {
    "recipeId": 7,
    "name": "카레라이스",
    "timeToCook": 40,
    "ingredient": ["카레가루", "감자", "당근", "양파", "고기"],
    "description": "채소와 고기를 넣고 끓인 카레를 밥과 함께 먹는 요리입니다.",
    "imageUrl": "http://fiscom/300/406",
    "process": [
      "야채와 고기를 볶는다.",
      "물을 넣고 끓인다.",
      "카레가루를 넣고 농도를 맞춘다."
    ]
  },
  {
    "recipeId": 8,
    "name": "바질페스토 파스타",
    "timeToCook": 22,
    "ingredient": ["스파게티면", "바질페스토", "올리브오일", "파르메산 치즈"],
    "description": "상큼한 바질페스토로 만드는 파스타입니다.",
    "imageUrl": "http://fiscom/300/407",
    "process": [
      "면을 삶는다.",
      "바질페스토와 올리브오일을 팬에 넣고 약하게 데운다.",
      "면을 넣어 섞은 후 치즈를 뿌린다."
    ]
  }
];

//사용자 정보를 나타내는 곳
final Map<String, dynamic> userInfo = {
  // 'user1': {
  //     'likedRecipeId': [1, 2], //recordedRecipe는 좋아요를 누를 수 없음. 당연함 내가 먹은 음식을 기록하는 취지의 탭이기 때문에 선호도는 중요하지 않음.
  //     'recordedRecipe': <Map<String, dynamic>>[
  //         {
  //             "recipeId": 101,
  //             "name": "계란굴소스볶음밥",
  //             "timeToCook": 15,
  //             "ingredient": ["계란", "밥"],
  //             "description": "계란을 이용한 밥 요리입니다.",
  //             "imageUrl": "http://fiscom/300/400",
  //             "process": [
  //                 "프라이팬에 기름을 부어 달군다.",
  //                 "계란과 밥을 넣어 볶는다.",
  //                 "기호에 맞게 양념을 추가한다."
  //             ]
  //         },
  //         {
  //             "recipeId": 102,
  //             "name": "김치삼겹살볶음밥",
  //             "timeToCook": 20,
  //             "ingredient": ["김치", "밥"],
  //             "description": "김치를 이용한 밥 요리입니다.",
  //             "imageUrl": "http://fiscom/300/401",
  //             "process": [
  //                 "프라이팬에 기름을 두르고 김치를 볶는다.",
  //                 "밥을 넣고 볶는다.",
  //                 "간을 맞춘다."
  //             ]
  //         },
  //     ],
  // }
};

//AI가 만들어준 레시피라고 가정하기(지금은 목데이터 사용)
final Map<String, dynamic> aiMadeRecipe = {
  "recipeId": 30,
  "name": "AI표 계란볶음밥",
  "timeToCook": 15,
  "ingredient": ["계란", "밥"],
  "description": "계란을 이용한 밥 요리입니다.",
  "imageUrl": "http://fiscom/300/400",
  "process": [
    "프라이팬에 기름을 부어 달군다.",
    "계란과 밥을 넣어 볶는다.",
    "기호에 맞게 양념을 추가한다."
  ]
};