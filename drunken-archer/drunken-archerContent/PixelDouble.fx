texture ScreenTexture;
 
// Our sampler for the texture, which is just going to be pretty simple
sampler TextureSampler = sampler_state
{
    Texture = <ScreenTexture>;
};

float4 PixelShaderFunction(float2 Tex: TEXCOORD0) : COLOR0
{
    Tex.x = Tex.x / 2;
	Tex.y = Tex.y / 2;

	float4 color = tex2D(TextureSampler, Tex);
    return color;
	//return float4(1, 0, 0, 1);
}

technique PostProcess
{
    pass P0
    {
        // TODO: set renderstates here.
		PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
