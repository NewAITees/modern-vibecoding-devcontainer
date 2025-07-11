# Python Development Rules

## Import Organization
以下の順序でimportを記述する：

1. 標準ライブラリ
2. サードパーティライブラリ
3. ローカルインポート

```python
# 標準ライブラリ
import os
from pathlib import Path
from typing import List, Optional

# サードパーティ
import pydantic
from fastapi import FastAPI

# ローカル
from src.your_package import models
```

## Error Handling
- 具体的な例外クラスを使用する
- 適切なログを出力する
- ユーザーフレンドリーなエラーメッセージを提供する

```python
try:
    result = risky_operation()
except ValueError as e:
    logger.error(f"Invalid value provided: {e}")
    raise HTTPException(status_code=400, detail="Invalid input")
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    raise HTTPException(status_code=500, detail="Internal server error")
```

## Type Hints
- すべての関数に型ヒントを付ける
- 戻り値の型も明記する
- Anyタイプは最終手段として使用

```python
def process_data(data: List[Dict[str, Any]]) -> Optional[ProcessedData]:
    """データを処理する関数"""
    if not data:
        return None
    return ProcessedData(items=data)
```

## Function Design
- 関数は単一責任を持つ
- 引数は5個以内に抑える
- 純粋関数を優先する

```python
def calculate_total(items: List[Item]) -> Decimal:
    """アイテムリストの合計を計算する"""
    return sum(item.price for item in items)
```

## Class Design
- データクラスはpydanticを使用
- 継承よりもコンポジションを優先
- プライベートメソッドは_で始める

```python
class UserService:
    def __init__(self, repository: UserRepository) -> None:
        self._repository = repository
    
    def create_user(self, user_data: CreateUserRequest) -> User:
        """ユーザーを作成する"""
        return self._repository.create(user_data)
```

## Security Rules
- 秘匿情報をログに出力しない
- 入力値検証を必ず行う
- SQLインジェクション対策を実施
- 環境変数で設定を管理

```python
# 悪い例
logger.info(f"User password: {password}")

# 良い例
logger.info(f"User {user.id} authenticated successfully")
```