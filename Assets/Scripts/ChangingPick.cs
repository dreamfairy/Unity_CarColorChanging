using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangingPick : MonoBehaviour
{
    public float Duration = 5f;
    public Color ChaningColor = Color.white;
    public Color PrevColor = Color.white;
    private float _LastClickTime;

    private Color[] ColorRange = { Color.white, Color.black, Color.red, Color.yellow, Color.blue, Color.green, Color.cyan, Color.grey };
    // Start is called before the first frame update
    void Start()
    {
        Shader.SetGlobalColor("_ChangePrevColor", PrevColor);
    }

    // Update is called once per frame
    void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {
            HandleClick();
        }
    }

    void HandleClick()
    {
        if((Time.timeSinceLevelLoad - _LastClickTime) < Duration * 2)
        {
            return;
        }

        _LastClickTime = Time.timeSinceLevelLoad;

        PrevColor = ChaningColor;
        ChaningColor = ColorRange[Random.Range(0, ColorRange.Length)];

        RaycastHit hitInfo;
        Physics.Raycast(Camera.main.ScreenPointToRay(Input.mousePosition), out hitInfo, 100, 1 << LayerMask.NameToLayer("Car"));
        if(hitInfo.transform)
        {
            Shader.SetGlobalVector("_ChangeParams", new Vector4(hitInfo.point.x, hitInfo.point.y, hitInfo.point.z, 1));
            Shader.SetGlobalVector("_ChangeTime", new Vector4(Duration, Time.timeSinceLevelLoad, 0, 1));
            Shader.SetGlobalColor("_ChangeColor", ChaningColor);
            Shader.SetGlobalColor("_ChangePrevColor", PrevColor);
        }
    }
}
