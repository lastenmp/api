from fastapi import FastAPI, UploadFile, File, HTTPException, Form
from fastapi.responses import Response
import pypandoc_binary   # Bundles Pandoc — no external install needed
import pypandoc
import os

app = FastAPI(
    title="MD → DOCX Converter",
    description="Upload .md file → download .docx (running on Render)",
)

@app.post("/convert")
async def convert_md_file_to_docx(
    md_file: UploadFile = File(...),
    output_filename: str = Form("output.docx"),
    extra_args: str = Form("", description="Optional Pandoc flags (space separated)")
):
    if not md_file.filename.lower().endswith((".md", ".markdown")):
        raise HTTPException(status_code=400, detail="Only .md or .markdown files allowed")

    content = await md_file.read()
    try:
        md_text = content.decode("utf-8")
    except UnicodeDecodeError:
        raise HTTPException(status_code=400, detail="File must be valid UTF-8 text")

    try:
        docx_bytes = pypandoc.convert_text(
            md_text,
            "docx",
            format="md",
            extra_args=extra_args.strip().split() if extra_args else []
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Conversion failed: {str(e)}")

    return Response(
        content=docx_bytes,
        media_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        headers={"Content-Disposition": f'attachment; filename="{output_filename}"'}
    )


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "pandoc_version": pypandoc.get_pandoc_version(),
        "port": os.getenv("PORT", "10000"),
        "note": "using pypandoc-binary"
    }
