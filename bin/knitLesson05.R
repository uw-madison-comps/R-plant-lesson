require(knitr)

src_rmd <- "_episodes_rmd/05-advanced-lesson.Rmd"
dest_md <- "_episodes/05-advanced-lesson.md"

## knit the Rmd into markdown
knitr::knit(src_rmd, output = dest_md)
