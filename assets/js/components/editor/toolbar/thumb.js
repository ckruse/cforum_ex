import React from "react";

export default class Thumb extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = { loading: false, thumb: undefined, file: this.props.file };

    if (this.state.file) {
      this.readFile(this.state.file);
    }
  }

  readFile(file) {
    const reader = new FileReader();
    reader.onloadend = () => this.setState({ loading: false, thumb: reader.result });
    reader.readAsDataURL(file);
  }

  componentDidUpdate() {
    if (this.props.file !== this.state.file) {
      this.setState({ loading: true, file: this.props.file, thumb: undefined }, () => {
        if (this.props.file) {
          this.readFile(this.props.file);
        }
      });
    } else if (this.state.file && !this.state.thumb) {
      this.readFile(this.state.file);
    }
  }

  render() {
    const { loading, thumb, file } = this.state;

    if (loading || !file) {
      return null;
    }

    return <img src={thumb} alt={file.name} className="cf-dropzone-thumbnail" />;
  }
}
