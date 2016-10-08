shader "xuhonghua/SnowShader"{

Properties {
		//原Texture
        _MainTex ("Base (RGB)", 2D) = "white" {}

        //法线贴图
        _Bump ("Bump/法线贴图", 2D) = "bump" {}
        
        _Snow ("Snow Level", Range(0,1) ) = 0
    	_SnowColor ("Snow Color", Color) = (1.0,1.0,1.0,1.0)
    	_SnowDirection ("Snow Direction", Vector) = (0,1,0)
    	_SnowDepth ("Snow Depth", Range(0,0.3)) = 0.1
    }
    SubShader {
    	//仅仅渲染不透明
        Tags { "RenderType"="Opaque" }
        //深度 200
        LOD 200

        CGPROGRAM
        //
        #pragma surface surf CustomDiffuse vertex:vert
        
        sampler2D _MainTex;

        //2
        sampler2D _Bump;                

		float _Snow;
		float4 _SnowColor;
		float4 _SnowDirection;
		float _SnowDepth;
		
        struct Input {
        	//点的坐标信息
            float2 uv_MainTex;
            //3
            float2 uv_Bump;
            
            float3 worldNormal; INTERNAL_DATA
        };

		//表面着色器
        void surf (Input IN, inout SurfaceOutput o) {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
    		o.Normal = UnpackNormal(tex2D(_Bump, IN.uv_Bump));

    		if (dot(WorldNormalVector(IN, o.Normal), _SnowDirection.xyz) > lerp(1,-1,_Snow)) {
        		o.Albedo = _SnowColor.rgb;
    		} else {
       			o.Albedo = c.rgb;
    		}

    		o.Alpha = c.a;
       }
        
        void vert (inout appdata_full v) {
    		float4 sn = mul(transpose(_Object2World) , _SnowDirection);
    		if(dot(v.normal, sn.xyz) >= lerp(1,-1, (_Snow * 2) / 3)) {
       			v.vertex.xyz += (sn.xyz + v.normal) * _SnowDepth * _Snow;
    		}
		}
        
        inline float4 LightingCustomDiffuse (SurfaceOutput s, fixed3 lightDir, fixed atten) {//lightDir光线方向 atten光衰减系数
        //dot (s.Normal, lightDir) s的法线方向与光线方向的点积  结果在(-1,1);
        // difLight就是光照强度 
    	float difLight = max(0, dot (s.Normal, lightDir));
    	float hLambert = difLight * 0.5 + 0.5;//让暗部更亮
    	float4 col;
    	//_LightColor0.rgb（由Unity根据场景中的光源得到的，它在Lighting.cginc中有声明）
    	col.rgb = s.Albedo * _LightColor0.rgb * (hLambert * atten * 2);
    	col.a = s.Alpha;
    	return col;
}
        ENDCG
    } 
    FallBack "Diffuse"
}