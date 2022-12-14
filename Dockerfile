FROM archlinux

# set time zone
RUN ln -s /usr/share/zoneinfo/UTC /etc/localtime

# set locale
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
RUN locale-gen
RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# install packages
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -Syu --noconfirm --needed                           \
            base                                               \
            base-devel                                         \
            poppler                                            \
            imagemagick                                        \
            wget                                               \
            xz                                                 \
            pandoc                                             \
            git                                                \
            lazygit                                            \
            bat                                                \
            rsync                                              \
            parallel                                           \
            vim                                                \
            nnn                                                \
            gcc-fortran                                        \
            openblas                                           \
            r

# quarto
RUN export QUARTO_VERSION=$(curl -s "https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v*([^"]+)".*/\1/') ;\
        curl -Lo quarto.tar.gz "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz" ;\
        mkdir -p /usr/local ; \
        tar -zxvf quarto.tar.gz -C /usr/local --strip-components=1 ;\
        rm quarto.tar.gz

# install R packages
# development packages
RUN R -e "install.packages(                                   \
      c(                                                      \
        'covr',                                               \
        'devtools',                                           \
        'distro',                                             \
        'ggplot2',                                            \
        'knitr',                                              \
        'lintr',                                              \
        'magick',                                             \
        'microbenchmark',                                     \
        'pdftools',                                           \
        'pkgdown',                                            \
        'ragg',                                               \
        'remotes',                                            \
        'rmarkdown',                                          \
        'rprojroot',                                          \
        'styler',                                             \
        'testthat',                                           \
        'tidyverse',                                          \
        'qpdf'                                                \
      ),                                                      \
      repos = 'https://packagemanager.rstudio.com/all/latest' \
    )"

RUN R -e "remotes::install_github( \
      c(                           \
        'rstudio/tinytex',         \
        'r-lib/cli',               \
        'r-lib/devtools',          \
        'r-hub/rhub'               \
      )                            \
    )"

RUN R -e "remotes::install_github( \
      c(                           \
        'jeksterslab/rProject'     \
      )                            \
    )"

RUN R -e "tinytex::install_tinytex( \
      bundle = 'TinyTeX-2',         \
      force = TRUE,                 \
      dir =  '/opt/TinyTeX'         \
    )"

ENV PATH="/opt/TinyTeX/bin/x86_64-linux:${PATH}"

# remove the packages downloaded to image's pacman cache dir.
RUN pacman -Sy --noconfirm pacman-contrib
RUN paccache -r -k0

# author
MAINTAINER "Ivan Jacob Agaloos Pesigan <r.jeksterslab@gmail.com>"

# extra metadata
LABEL description="rarch container."
