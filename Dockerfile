# ベースイメージはJetson用のL4T Ubuntu 22.04 JetPack 6.2
FROM nvcr.io/nvidia/l4t-base:r36.2.0

# 非対話モード設定
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# 必要モジュールのインストール
RUN apt-get update && apt-get install -y \
    locales \
    gnupg2 \
    lsb-release \
    software-properties-common \
    ca-certificates \
    curl \
    python3-pip \
    nano \
    && rm -rf /var/lib/apt/lists/*

# pip をアップグレード
RUN python3 -m pip install --upgrade pip setuptools wheel

# ROS2 リポジトリ設定
RUN ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') && \
    curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo $VERSION_CODENAME)_all.deb" && \
    dpkg -i /tmp/ros2-apt-source.deb

# ROS2 と MAVROS をインストール
RUN apt-get update && apt-get install -y \
    ros-humble-ros-base \
    ros-humble-mavros \
    ros-humble-mavros-extras \
    geographiclib-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# GeographicLibデータ
RUN geographiclib-get-geoids egm96-5 && \
    geographiclib-get-gravity egm96

# 環境設定
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# MAVROS の起動用スクリプトを作成
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

#MAVROS起動
ENTRYPOINT ["/entrypoint.sh"]

#CMD ["/bin/bash"]

