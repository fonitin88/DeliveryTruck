using UnityEngine;

public class Apple : Pickup //使用pickup這個script
{
    [SerializeField] float adjustChangeMoveSpeedAmount = 2f;

    LevelGenerator levelGenerator;

    public void Init(LevelGenerator levelGenerator)//可以「接收外部傳進來的變數」
    {
        this.levelGenerator = levelGenerator;

    }

    protected override void OnPickup()
    {
        levelGenerator.ChangeChunkMoveSpeed(adjustChangeMoveSpeedAmount);
    }
}
